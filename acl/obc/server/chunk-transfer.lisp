;;; -*- Mode: lisp; Syntax: ansi-common-lisp; Package: EXCL; Base: 10 -*-

(in-package :excl)

;;;
;;; (c) Copyright  1995-96, John C. Mallery
;;;     All Rights Reserved.
;;;

;;;------------------------------------------------------------------- 
;;;
;;; HTTP 1.1 CHUNKED TRANFER ENCODING OUTPUT STREAM
;;;

(eval-when (compile eval load)

(defun string-to-8-bit-vector (string &optional (start 0) (end (length string)))
  (loop with length = (- end start)
        with vector = (make-array length :element-type '(unsigned-byte 8))
        for idx1 upfrom start below end
        for idx2 upfrom 0
        do (setf (aref vector idx2) (char-code (aref string idx1)))
        finally (return (values vector length)))))

(defun 8-bit-vector-to-string (vector &optional (start 0) (end (length vector)))
  (loop with length = (- end start)
        with string = (make-array length :element-type *default-character-type*)
        for idx1 upfrom start below end
        for idx2 upfrom 0
        do (setf (aref string idx2) (code-char (aref vector idx1)))
        finally (return (values string length))))

(declaim (inline chunk-size-integer chunk-size-string))

(defun chunk-size-integer (hexidecimal &optional (start 0) (end (length hexidecimal)))
  "Decodes the size of a chunked transfer encoding from HEXIDECIMAL to an integer."
  (parse-integer hexidecimal :radix 16. :junk-allowed t :start start :end end))

(eval-when (compile eval load)
(defun chunk-size-string (size)
  "Encodes the size of a chunk for chunked transfer encoding from SIZE, an integer, to hexidecimal."
  (declare (values hexidecimal-size hexidecimal-digits))
  (let ((hex (write-to-string size :base 16. :readably nil)))
    (values hex (length hex)))))

;; pick the maximum 4-digit hex, FFFF
(eval-when (compile eval load)
(defconstant *default-chunk-size-vector* (string-to-8-bit-vector (chunk-size-string 65535)))

(defconstant *default-chunk-size-vector-length* (length *default-chunk-size-vector*)))

(declaim (inline write-8-bit-crlf write-chunk-size-header write-chunk-end-header))

(defun write-8-bit-crlf (conn &optional (write-buffer (conn-write-buffer conn)))
  (%put-byte write-buffer #.(char-code #\Return) (conn-write-count conn))
  (%put-byte write-buffer #.(char-code #\Linefeed) (incf (conn-write-count conn)))
  (incf (conn-write-count conn) 1)
  (incf (conn-bytes-transmitted conn) 2))

(defun write-chunk-size-header (conn chunk-size-vector chunk-size-vector-length
                                     &optional (write-buffer (conn-write-buffer conn)))
  (declare (fixnum chunk-size-vector-length))
  (loop for idx1 upfrom 0 below chunk-size-vector-length
        for idx2 upfrom (conn-write-count conn)
        for byte = (aref chunk-size-vector idx1)
        do (%put-byte write-buffer byte idx2)
        finally (incf (conn-write-count conn) chunk-size-vector-length)
                (incf (conn-bytes-transmitted conn) (the fixnum chunk-size-vector-length))))

(defun insert-chunk-size (conn size position chunk-size-vector-length
                               &optional (write-buffer (conn-write-buffer conn)))
  (multiple-value-bind (hex hex-digits)
      (chunk-size-string size)
    (declare (dynamic-extent hex))
    (unless (<= hex-digits chunk-size-vector-length)
      (error "Insufficient space in content-length header. ~D was allowed but ~D is needed."
             chunk-size-vector-length hex-digits))
    (loop for idx1 upfrom 0 below hex-digits
          for idx2 upfrom position
          for byte = (char-code (aref hex idx1))
          do (%put-byte write-buffer byte idx2)
          finally (loop for idx3 upfrom (1+ (the fixnum idx2))
                            upto (+ (the fixnum idx2)
                                    (- (the fixnum chunk-size-vector-length)
                                       (the fixnum hex-digits)))        ;pad with spaces
                        do (%put-byte write-buffer #.(char-code #\space) idx3)))
    size))

(defstruct (chunked-transfer-encoder
             (:print-function tcp-print-chunked-transfer-encoder)
             (:conc-name cte-))
  (chunk-output nil :type boolean)              ;whether output chunking is on or off
  (chunk-start 0 :type integer)
  (chunk-end 0 :type integer)
  (chunk-body-start 0 :type integer)
  (chunk-body-end 0 :type integer)
  (chunk-body-size 0 :type integer)
  (content-length-start 0 :type integer)
  (chunks-transmitted 0 :type integer)
  (chunk-function nil :type (or null function)))
  
(defun tcp-print-chunked-transfer-encoder (encoder stream ignore)
  (declare (ignore ignore))
  (print-unreadable-object (encoder stream :identity t :type t)
    (format stream "Chunking ~:[Off~;On~]; Transmitted: ~D ~:[~;;Function: ~:*~S~]" 
            (cte-chunk-output encoder) (cte-chunks-transmitted encoder) (cte-chunk-function encoder))))

(defun %note-chunk-body-start (conn &optional (encoder (conn-encoder conn))
                                    (write-buffer (conn-write-buffer conn)))
  (setf (cte-content-length-start encoder) (conn-write-count conn))
  (write-chunk-size-header conn *default-chunk-size-vector* *default-chunk-size-vector-length* write-buffer)
  (write-8-bit-crlf conn write-buffer)
  (setf (cte-chunk-body-start encoder) (conn-write-count conn)
        (cte-chunk-end encoder) (conn-write-bufsize conn))
  (decf (conn-write-bufsize conn) 2))

(defun %note-body-end (conn &optional(encoder (conn-encoder conn)) (write-buffer (conn-write-buffer conn))
                            &aux fctn)
  (let ((buffer-pos (conn-write-count conn)))
    (setf (cte-chunk-body-end encoder) buffer-pos)
    (insert-chunk-size conn
                       (- buffer-pos (cte-chunk-body-start encoder))
                       (cte-content-length-start encoder)
                       *default-chunk-size-vector-length*
                       write-buffer)
    (write-8-bit-crlf conn write-buffer)
    (setf (conn-write-bufsize conn) (cte-chunk-end encoder))
    (when (setq fctn (cte-chunk-function encoder))
      (funcall fctn (cte-chunk-body-start encoder) buffer-pos))
    (incf (cte-chunks-transmitted encoder))))

(defmethod chunk-transfer-encoding-mode ((s chunk-transfer-encoding-output-stream-mixin)
                                         &optional function &aux (conn (tcp-stream-conn s)))
  (check-type function (or null function))
  (tcp-force-output conn t)                     ;clear leading buffer space for now.
  (let  ((encoder (or (conn-encoder conn)
                      (setf (conn-encoder conn) (make-chunked-transfer-encoder)))))
    (setf (cte-chunk-output encoder) t
          (cte-chunk-function encoder) function
          (cte-chunks-transmitted encoder) 0
          (cte-chunk-start encoder) (conn-write-count conn))))

(defmethod note-first-chunk ((s chunk-transfer-encoding-output-stream-mixin))
  (%note-chunk-body-start (tcp-stream-conn s)))

(defmethod note-last-chunk ((s chunk-transfer-encoding-output-stream-mixin) &optional footers-plist)
  (let* ((conn (tcp-stream-conn s))
         (encoder (conn-encoder conn))
         (write-buffer (conn-write-buffer conn)))
    (setf (cte-chunk-output encoder) nil) ;; Prevent standard output buffer send and setup from occurring again.
    (cond ;; if no data written to body yet, convert to end header
     ((eql (cte-chunk-body-start encoder) (conn-write-count conn))
      (insert-chunk-size conn 0 (cte-content-length-start encoder) *default-chunk-size-vector-length* write-buffer))
     (t (%note-body-end conn encoder write-buffer)
        (%put-byte write-buffer #.(char-code #\0) (conn-write-count conn))
        (incf (conn-write-count conn))
        (write-8-bit-crlf conn write-buffer)))
    ;; write the footers
    (http::write-headers s footers-plist t)
    (force-output s)))

;; Advice for TCP before sending the current output buffer
;; Implemented as around methods on stream with a consumer/provider model of stream buffers
(defmethod tcp-encoder-before-tcp-send ((encoder chunked-transfer-encoder) conn)
  (when (cte-chunk-output encoder)
    (%note-body-end conn encoder)))

;; Advice for TCP after setting up a new output buffer
;; Implemented as around methods on stream with a consumer/provider model of stream buffers
(defmethod tcp-encoder-after-tcp-send ((encoder chunked-transfer-encoder) conn)
  (when (cte-chunk-output encoder)
    (setf (cte-chunk-start encoder) (conn-write-count conn))
    (%note-chunk-body-start conn encoder)))


;;;------------------------------------------------------------------- 
;;;
;;; HTTP 1.1 CHUNKED TRANSFER DECODING
;;;

(defstruct (chunked-transfer-decoder
             (:print-function tcp-print-chunked-transfer-decoder)
             (:conc-name ctd-))
  (chunked-input nil :type boolean)             ;whether output input-chunking is on or off
  (inside-input-chunk-p nil :type boolean)      ; whether we're processing a chunk
  (old-mode nil :type symbol)
  (input-content-length 0 :type integer)
  (input-chunk-size 0 :type integer)
  (input-scan-start 0 :type integer)
  (input-scan-end 0 :type integer)
  (input-scan-length 0 :type integer)
  (input-chunk-content-length 0 :type integer)
  (input-chunk-crosses-buffer-p nil :type boolean)
  (input-buffer-limit 0 :type integer)
  (input-chunks-received 0 :type integer)
  (input-chunk-size-vector nil :type (or null vector))
  (input-chunk-args-vector nil :type (or null vector)))

(defun tcp-print-chunked-transfer-decoder (decoder stream ignore)
  (declare (ignore ignore))
  (print-unreadable-object (decoder stream :identity t :type t)
    (format stream "Chunking ~:[Off~;On~]; Received: ~D"
            (ctd-chunked-input decoder) (ctd-input-chunks-received decoder))))

;; tracing can be done by setting http:*debug-client* to :chunk-transfer-decoding
#+ignore
(defmacro with-chunk-transfer-decoding-traced (&body body)
  `(case http:*debug-client*
     (:chunk-transfer-decoding ,@body)))

(defmacro with-chunk-transfer-decoding-traced (&body body)
  (declare (ignore body))
  `(progn))

(defun read-cr (conn)
  (with-chunk-transfer-decoding-traced
    (format *error-output* "Read: CR "))
  (let ((byte (tcp-read-byte conn)))
    (or (= byte #.(char-code #\return))
        (error "~@C was found  when , not ~@C  was expected  in chunked transfer decoding." (code-char byte) #\return))))

(defun read-lf (conn)
  (with-chunk-transfer-decoding-traced
    (format *error-output* "Read: LF "))
  (let ((byte (tcp-read-byte conn)))
    (or (= byte #.(char-code #\linefeed))
        (error "~@C was found  when , not ~@C  was expected  in chunked transfer decoding." (code-char byte) #\linefeed))))

(defconstant *input-chunk-size-vector-size* 6
  "Controls the standard size of the hex vector resource used to read http chunk sizes.")

(defun allocate-input-chunk-size-vector (decoder)
  (cond ((ctd-input-chunk-size-vector decoder))
        (t (let ((v (make-array *input-chunk-size-vector-size* :element-type *default-character-type*
                                :adjustable t :fill-pointer t)))
             (setf (fill-pointer v) 0
                   (ctd-input-chunk-size-vector decoder) v)
             v))))

(defun deallocate-input-chunk-size-vector (decoder vector)
  (setf (fill-pointer vector) 0
        (ctd-input-chunk-size-vector decoder) vector)) 

(defparameter *input-chunk-args-vector-size* 130
   "Controls the standard size of the vector resource used to read HTTP chunk  arguments.") 

(defun allocate-input-chunk-args-vector (decoder)
  (cond ((ctd-input-chunk-args-vector decoder))
        (t (let ((v (make-array *input-chunk-args-vector-size* :element-type *default-character-type*
                                :adjustable t :fill-pointer t)))
             (setf (fill-pointer v) 0
                   (ctd-input-chunk-args-vector decoder) v)
             v))))

(defun deallocate-input-chunk-args-vector (decoder vector)
  (setf (fill-pointer vector) 0
        (ctd-input-chunk-args-vector decoder) vector))

(defun grow-chunk-string (string &optional (delta 10) (size (array-total-size string)))
  (declare (values new-string new-size)
           (fixnum delta size))
  (let ((n-size (+ size delta)))
    (values (adjust-array string n-size :element-type *default-character-type* :fill-pointer t)
            n-size)))

(defun read-chunk-size (conn hex-vector)
  (declare (values integer-size byte hex-vector)
           (type string hex-vector)
           (optimize (speed 3) (safety 0)))
  (with-chunk-transfer-decoding-traced
    (format *error-output* "~&Read-Chunk-Size-Start: ~D~&" (conn-read-count conn)))
  (let* ((hex-vector-size (array-total-size hex-vector))
         (idx2 (fill-pointer hex-vector)))
    (loop for byte = (tcp-read-byte conn)
          until (member byte '#.(mapcar #'char-code '(#\; #\return #\linefeed)) :test #'=)
          do (unless (< idx2 hex-vector-size)
               (multiple-value-setq (hex-vector hex-vector-size)
                 (grow-chunk-string hex-vector 10. hex-vector-size)))
          do (unless (= byte #.(char-code #\space))
               (setf (aref hex-vector idx2) (code-char byte))
               (incf idx2))
          finally (setf (fill-pointer hex-vector) idx2)
                  (with-chunk-transfer-decoding-traced
                    (format *error-output* "~&Read-Chunk-Size-End: ~D (~S)~&" (conn-read-count conn) hex-vector))
                  (return (values (chunk-size-integer hex-vector) byte hex-vector))))) 

(defun parse-chunk-size-arguments (conn vector byte)
  (declare (values args byte args-vector))
  (with-chunk-transfer-decoding-traced
    (format *error-output* "~&Parse-Chunk-Size-Args-Start: ~D~&" (conn-read-count conn)))
  (labels ((return-values (vector byte)
             (let ((end (fill-pointer vector)))
               (values (if (zerop end)
                           nil
                           (http::parse-equal-sign-delimited-pairs vector 0 end #\; nil))
                       byte 
                       vector)))                   
           (do-collect-args (conn vector &aux byte)
             (declare (type vector string)
                      (optimize (speed 3) (safety 0)))
             (loop with idx = (fill-pointer vector)
                   with vector-size = (array-total-size vector)
                   do (setq byte  (tcp-read-byte conn))
                   until (member byte '#.(mapcar #'char-code '(#\Return #\Linefeed)))
                   do (unless (< idx vector-size)
                        (multiple-value-setq (vector vector-size)
                          (grow-chunk-string vector 100. vector-size)))
                   do (setf (aref vector idx) (code-char byte))
                      (incf idx)
                   finally (setf (fill-pointer vector) idx))
             (ecase byte
               (#.(char-code #\Return)
                (read-lf conn)
                (return-values vector #.(char-code #\Linefeed)))
               (#.(char-code #\Linefeed)
                (return-values vector #.(char-code #\Linefeed)))))) 
    (multiple-value-prog1
      (case byte
        (#.(char-code #\Return)
         (read-lf conn)
         (setf (fill-pointer vector) 0)
         (return-values vector #.(char-code #\Linefeed)))
        (#.(char-code #\Linefeed)
         (setf (fill-pointer vector) 0)
         (return-values vector #.(char-code #\Linefeed)))
        ;; skip over spaces until reaching the argument delimiter
        (t (do-collect-args conn vector)))
      (with-chunk-transfer-decoding-traced
        (format *error-output* "~&Parse-Chunk-Size-Args-End: ~D (~S)~&" (conn-read-count conn) vector)))))

(defun %read-chunk-size (conn  &optional (decoder (conn-decoder conn)))
   (declare (values chunk-size args))
   (let* ((stream (conn-stream conn))
             (mode (ctd-old-mode decoder))
             (hex-vector (allocate-input-chunk-size-vector decoder))
             (args-vector (allocate-input-chunk-args-vector decoder)))
      (unwind-protect
         (prog (chunk-size byte chunk-size-args)
            (binary-input-mode (conn-stream conn))
            (multiple-value-setq (chunk-size byte hex-vector)
                (read-chunk-size conn hex-vector))
            (multiple-value-setq (chunk-size-args byte args-vector)
                (parse-chunk-size-arguments  conn args-vector byte))
            (with-chunk-transfer-decoding-traced
                (format *error-output* "~&Chunk-Size: ~D ~20TChunk-Args: ~S~&" chunk-size chunk-size-args))
            ;;return the values
            (return (values chunk-size chunk-size-args)))
         ;; clean up forms
         (deallocate-input-chunk-size-vector decoder hex-vector)
         (deallocate-input-chunk-args-vector decoder args-vector)
         (set-input-mode stream mode))))

(define-condition end-of-chunk-transfer-decoding
                  (end-of-file)
  ()
  (:documentation "Signalled when a complete HTTP resource has been successfully transferred."))

(defun %note-chunk-start  (conn &optional (decoder (conn-decoder conn)))
  (multiple-value-bind (chunk-size chunk-args)
      (%read-chunk-size conn decoder)
    (declare (integer chunk-size)
             (ignore chunk-args))               ; don't know what to do with these yet.-- JCMa 8/28/1996.
    (with-chunk-transfer-decoding-traced
      (format *error-output* "~&Start-Chunk: ~D~&" (conn-read-count conn)))
    (cond ((zerop chunk-size)
           (setf (ctd-inside-input-chunk-p decoder) nil
                 (ctd-input-chunk-size decoder) 0
                 (ctd-input-scan-start decoder) 0
                 (ctd-input-scan-end decoder) 0
                 (ctd-input-scan-length decoder) 0
                 (ctd-input-chunk-content-length decoder) 0
                 (ctd-input-chunk-crosses-buffer-p decoder) nil)
           (signal 'end-of-chunk-transfer-decoding))
          (t (let* ((start (the integer (conn-read-count conn)))
                    (end (max (- start chunk-size)  0))
                    (length (- start end)))
               (setf (ctd-input-chunk-size decoder) chunk-size
                     (ctd-inside-input-chunk-p decoder) t
                     (ctd-input-scan-start decoder) start
                     (ctd-input-scan-end decoder) end
                     (ctd-input-scan-length decoder) length
                     (ctd-input-chunk-content-length decoder) length
                     (ctd-input-chunk-crosses-buffer-p decoder) (> chunk-size length)
                     (ctd-input-buffer-limit decoder) end       ; restore this count after chunk read
                     (conn-read-count conn) length)     ; set the end of buffer
               (incf (ctd-input-content-length decoder) chunk-size)
               (with-chunk-transfer-decoding-traced
                 (format *error-output* "~&Start-Count: ~D~&" (conn-read-count conn))))))))

(defun %note-chunk-continue (conn &optional (decoder (conn-decoder conn)))
  (let* ((start (the integer (conn-read-count conn)))
         (chunk-size (the integer (ctd-input-chunk-size decoder)))
         (chunk-content-length (the integer (ctd-input-chunk-content-length decoder)))
         (end (max (- start (- chunk-size chunk-content-length)) 0))
         (length (- start end)))
    (setf (ctd-input-scan-start decoder) start
          (ctd-input-scan-end  decoder) end
          (ctd-input-scan-length  decoder) length
          (ctd-input-buffer-limit decoder) end  ; restore this count after chunk read
          (conn-read-count conn) length)        ; set the end of buffer
    (incf (ctd-input-chunk-content-length decoder) length)
    (setf (ctd-input-chunk-crosses-buffer-p decoder) (> chunk-size (ctd-input-chunk-content-length decoder)))))

(defun %note-chunk-end (conn decoder)
  (with-chunk-transfer-decoding-traced
    (format *error-output* "~&End-Count: ~D~&" (conn-read-count conn)))
  (setf (ctd-input-chunk-size decoder) 0        ; back to no chunk size state to control new buffer operations
        (ctd-inside-input-chunk-p decoder) nil
        (conn-read-count conn) (ctd-input-scan-end decoder))    ; size of buffer restored
  (set-input-mode (conn-stream conn) :binary)
  (with-chunk-transfer-decoding-traced
    (format *error-output* "~&End-Chunk: ~D~&" (conn-read-count conn)))
  (read-cr conn)
  (read-lf conn)
  (set-input-mode (conn-stream conn) (ctd-old-mode decoder)))

(defmethod chunk-transfer-decoding-mode ((s chunk-transfer-decoding-input-stream-mixin))
  (let* ((conn (tcp-stream-conn s))
         (decoder (or (conn-decoder conn)
                      (setf (conn-decoder conn) (make-chunked-transfer-decoder)))))
    (setf (ctd-chunked-input decoder) t
          (ctd-old-mode decoder) (input-mode s)
          (ctd-input-content-length decoder) 0
          (ctd-input-scan-length decoder) 0)
    (%note-chunk-start conn decoder)))

(defmethod chunk-transfer-content-length  ((s chunk-transfer-decoding-input-stream-mixin) &aux conn decoder)
  (cond ((and (setq conn (tcp-stream-conn s))
              (setq decoder (conn-decoder conn))
              (ctd-chunked-input decoder))
         (ctd-input-content-length decoder))
        (t (error "~S is not in chunked transfer decoding mode." s)))) 

(defmethod chunk-transfer-content-length-header ((s chunk-transfer-decoding-input-stream-mixin)&aux conn decoder)
  (cond ((and (setq conn (tcp-stream-conn s))
              (setq decoder (conn-decoder conn))
              (ctd-chunked-input decoder))
         (http::allocate-content-length-header (ctd-input-content-length decoder)))
        (t (error "~S is not in chunked transfer decoding mode." s))))

(defmethod chunk-transfer-decoding-mode-end ((s chunk-transfer-decoding-input-stream-mixin))
  (let* ((conn (tcp-stream-conn s))
         (decoder (conn-decoder conn)))
    (setf (ctd-chunked-input decoder) nil
          (ctd-input-chunk-size decoder) 0
          (ctd-input-scan-start decoder) 0
          (ctd-input-scan-end decoder) 0
          (ctd-input-scan-length decoder) 0
          (ctd-input-chunk-content-length decoder) 0
          (ctd-input-chunk-crosses-buffer-p decoder) nil)))

;; interface to mactcp.lisp
#+mcl
(defmethod tcp-get-next-input-buffer :around ((conn conn) &optional (check-eof-p t) need-more-data-p &aux decoder) 
  (with-chunk-transfer-decoding-traced
    (format *error-output* "~&Next-Buffer-Start: ~D~&" (conn-read-count conn)))
  (multiple-value-prog1
    (cond ((not (and (setq decoder (conn-decoder conn))
                     (ctd-chunked-input decoder)
                     (or (ctd-inside-input-chunk-p decoder)     ;we're not playing with buffer lengths
                         (eql -1 (ctd-input-chunk-size decoder)))))     ; need to start next chunk
           (with-chunk-transfer-decoding-traced
             (format *error-output* "~&Next-Buffer: Standard~&"))
           (call-next-method conn check-eof-p need-more-data-p))
          ((ctd-input-chunk-crosses-buffer-p decoder)
           (multiple-value-prog1
             (call-next-method conn check-eof-p need-more-data-p)
             (%note-chunk-continue conn decoder)))
          (t (unless (eql -1 (ctd-input-chunk-size decoder))
               (%note-chunk-end conn decoder))
             (multiple-value-prog1
               (call-next-method conn check-eof-p need-more-data-p)
               (%note-chunk-start conn decoder))))
    (with-chunk-transfer-decoding-traced
      (format *error-output* "~&Next-Buffer-End: ~D~&" (conn-read-count conn)))))

;; interface to mactcp.lisp
#+mcl
(defmethod tcp-advance-input-buffer :around (conn &optional advance-p)
  (with-chunk-transfer-decoding-traced
    (format *error-output* "~&Advance-Buffer-Start: ~D~&" (conn-read-count conn)))
  (multiple-value-prog1
    (let ((decoder (conn-decoder conn)))
      (cond ((not (and (setq decoder (conn-decoder conn))
                       (ctd-chunked-input decoder)
                       (ctd-inside-input-chunk-p decoder)))     ;we're not playing with buffer lengths
             (with-chunk-transfer-decoding-traced
               (format *error-output* "~&Advance-Buffer: Standard~&"))
             (call-next-method conn advance-p))
            ((ctd-input-chunk-crosses-buffer-p decoder)
             (call-next-method conn advance-p)
             (unless (zerop (conn-read-count conn))     ; no more data available
               (%note-chunk-continue conn decoder)))
            (t (%note-chunk-end conn decoder)
               (cond ((zerop (conn-read-count conn))    ; no more data available
                      (setf (ctd-input-chunk-size decoder) -1))
                     (t (%note-chunk-start conn decoder))))))
    (with-chunk-transfer-decoding-traced
	(format *error-output* "~&Advance-Buffer-End: ~D~&" (conn-read-count conn)))))

