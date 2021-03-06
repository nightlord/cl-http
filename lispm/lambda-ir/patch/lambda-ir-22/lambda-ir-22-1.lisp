;;; -*- Mode: LISP; Syntax: Common-lisp; Package: LAMBDA-IR; Base: 10; Patch-File: T -*-
;;; Patch file for LAMBDA-IR version 22.1
;;; Reason: Function LR::SAVE-IMAGE:  add estimated-file-size argument.
;;; Function (CLOS:METHOD LR::SAVE-IMAGE (LR::DOCUMENT-UNIVERSE T)):  reimplement
;;; Function LR:READ-ONE:  declare values.
;;; Function LR::LOAD-IMAGE:  add values declaration.
;;; Written by JCMa, 9/09/99 13:36:24
;;; while running on Publications Y2K Testbed from HOST6:/usr/lib/symbolics/eop-world-pub6-host6-990831.vlod
;;; with Open Genera 2.0, Genera 8.5, Logical Pathnames Translation Files NEWEST,
;;; Lock Simple 437.0, Version Control 405.0, Compare Merge 404.0, CLIM 72.0,
;;; Genera CLIM 72.0, PostScript CLIM 72.0, CLIM Documentation 72.0,
;;; Statice Runtime 466.1, Statice 466.0, Statice Browser 466.0,
;;; Statice Server 466.2, Statice Documentation 426.0, Joshua 237.3,
;;; Joshua Documentation 216.0, Image Substrate 440.4,
;;; Essential Image Substrate 433.0, Mailer 438.0, Showable Procedures 36.3,
;;; Binary Tree 34.0, Working LispM Mailer 8.0, Experimental HTTP Server 70.3,
;;; Experimental W3 Presentation System 8.0,
;;; Experimental CL-HTTP Server Interface 53.0,
;;; Experimental Symbolics Common Lisp Compatibility 4.0,
;;; Experimental Comlink Packages 6.0, Experimental Comlink Utilities 10.0,
;;; Experimental COMLINK Cryptography 2.0, Experimental Routing Taxonomy 9.0,
;;; Experimental COMLINK Database 11.7, Experimental Email Servers 12.0,
;;; Experimental Comlink Customized LispM Mailer 7.0,
;;; Experimental Dynamic Forms 14.0, Experimental Communications Linker Server 39.2,
;;; Experimental Lambda Information Retrieval System 22.0,
;;; Experimental Comlink Documentation Utilities 6.0,
;;; Experimental White House Publication System 25.6,
;;; Experimental WH Automatic Categorization System 15.5,
;;; 8-5-Genera-Local-Patches 1.0, 39-COMLINK-Local-Patches 1.11,
;;; Publications-Server-Local-Patches 1.4, Ivory Revision 5, VLM Debugger 329,
;;; Genera program 8.16, DEC OSF/1 V4.0 (Rev. 205),
;;; 1260x932 24-bit TRUE-COLOR X Screen HOST6:0.0 with 224 Genera fonts (DECWINDOWS Digital Equipment Corporation Digital UNIX V4.0 R1),
;;; Machine serial number 1719841853,
;;; Local flavor function patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;LOCAL-FLAVOR-FUNCTION-PATCH-MARK2),
;;; Get emb file host patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;GET-EMB-FILE-HOST-PATCH),
;;; Get mailer home location from namespace (from EOP:CONFIG;MAIL-SERVER;PATCHES;MAILER-ENVIRONMENT-PATCH),
;;; Consider internet-domain-name when matching names to file hosts (from EOP:CONFIG;MAIL-SERVER;PATCHES;PATHNAME-HOST-NAMEP-PATCH.LISP.2),
;;; Parse pathname patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;PARSE-PATHNAME-PATCH),
;;; Get internal event code patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;GET-INTERNAL-EVENT-CODE-PATCH),
;;; AutoLogin (from EOP:CONFIG;MAIL-SERVER;PATCHES;AUTO-LOGIN.LISP.1),
;;; Generate an error any time there domain system tries to create a bogus host object for the local host. (from EOP:CONFIG;MAIL-SERVER;PATCHES;DETECT-BOGUS-HOST.LISP.1),
;;; Set Mailer UID variables for current namespace. (from EOP:CONFIG;MAIL-SERVER;PATCHES;MAILER-UID.LISP.1),
;;; Provide Switch between EOP and MIT sources. (from EOP:CONFIG;MAIL-SERVER;PATCHES;MIT-SOURCE.LISP.1),
;;; Make FS:USER-HOMEDIR look in the namespace as one strategy. (from EOP:CONFIG;MAIL-SERVER;PATCHES;USER-HOMEDIR.LISP.2),
;;; Local uid patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;LOCAL-UID-PATCH),
;;; Statice log clear patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;STATICE-LOG-CLEAR-PATCH),
;;; Make compiled-function-spec-p of CLOS class symbol return NIL instead of erring (from EOP:CONFIG;MAIL-SERVER;PATCHES;COMPILED-FUNCTION-SPEC-P-PATCH.LISP.1),
;;; Improve mailer host parsing (from EOP:CONFIG;MAIL-SERVER;PATCHES;PARSE-MAILER-HOST-PATCH.LISP.1),
;;; Make native domain name host patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;MAKE-NATIVE-DOMAIN-NAME-HOST-PATCH.LISP.1),
;;; Domain query cname loop patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;DOMAIN-QUERY-CNAME-LOOP-PATCH.LISP.1),
;;; Increase disk wired wait timeout from 30 to 90 seconds (from DISTRIBUTION|DIS-EMB-HOST:/db/eop.sct/eop/config/mail-server/patches/disk-wait-90-patch.),
;;; Checkpoint command patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;CHECKPOINT-COMMAND-PATCH.LISP.9),
;;; Domain Fixes (from CML:MAILER;DOMAIN-FIXES.LISP.33),
;;; Don't force in the mail-x host (from CML:MAILER;MAILBOX-FORMAT.LISP.24),
;;; Make Mailer More Robust (from CML:MAILER;MAILER-FIXES.LISP.15),
;;; Patch TCP hang on close when client drops connection. (from HTTP:LISPM;SERVER;TCP-PATCH-HANG-ON-CLOSE.LISP.10),
;;; Add CLIM presentation and text style format directives. (from FV:SCLC;FORMAT.LISP.20),
;;; Fix Statice Lossage (from CML:LISPM;STATICE-PATCH.LISP.3),
;;; Make update schema work on set-value attributes with accessor names (from CML:LISPM;STATICE-SET-VALUED-UPDATE.LISP.1),
;;; COMLINK Mailer Patches. (from CML:LISPM;MAILER-PATCH.LISP.107),
;;; Clim patches (from CML:DYNAMIC-FORMS;CLIM-PATCHES.LISP.48),
;;; Increase disk wired wait timeout from 30 to 900 seconds (from EOP:CONFIG;MAIL-SERVER;PATCHES;DISK-WAIT-900-PATCH.LISP.1),
;;; Tcp implementation error intsrumentation patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;TCP-IMPLEMENTATION-ERROR-INTSRUMENTATION-PATCH.LISP.NEWEST),
;;; Increase packet buffers patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;INCREASE-PACKET-BUFFERS-PATCH.LISP.NEWEST),
;;; Close tcb patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;CLOSE-TCB-PATCH),
;;; Get output segment patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;GET-OUTPUT-SEGMENT-PATCH.LISP.NEWEST),
;;; Expansion buffer hack patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;EXPANSION-BUFFER-HACK-PATCH.LISP.1),
;;; Nfs directory list fast patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;NFS-DIRECTORY-LIST-FAST-PATCH.LISP.NEWEST),
;;; Gc report patch (from EOP:MAIL-SERVER;PATCHES;GC-REPORT-PATCH.LISP.1),
;;; Pathname patch (from EOP:MAIL-SERVER;PATCHES;PATHNAME-PATCH.LISP.2),
;;; Pathname2 patch (from EOP:MAIL-SERVER;PATCHES;PATHNAME2-PATCH.LISP.3),
;;; Fix NFS brain damage. (from EOP:MAIL-SERVER;PATCHES;NFS-PATCH.LISP.8),
;;; Log patch (from EOP:MAIL-SERVER;PATCHES;LOG-PATCH.LISP.2),
;;; Vlm namespace append patch (from EOP:MAIL-SERVER;PATCHES;VLM-NAMESPACE-APPEND-PATCH.LISP.7),
;;; Bad rid error patch (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-1.LISP.1),
;;; Copy database patch (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-2.LISP.1),
;;; Cml bulk mail patch (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-6.LISP.1),
;;; Encode integer date patch (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-7.LISP.1),
;;; Fix year 199,
;;; from silly browsers (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-8.LISP.1),
;;; Fix wddi obsolete references (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-9.LISP.1),
;;; Ccc sign document enable services (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-10.LISP.1),
;;; End date for wh pub default (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-11.LISP.2),
;;; Redirect to WWW.PUB.WHITEHOUSE.GOV (from EOP:PUB;HTTP;REDIRECT-TO-PRIMARY.LISP.12),
;;; Some holiday favorites for Pete (from EOP:LOCAL-PATCHES;PUBLICATIONS;PUBLICATIONS-SERVER-LOCAL-PATCHES-1-4.LISP.2).

;;; Patch file for LAMBDA-IR version 22.1
;;; Written by JCMa, 9/09/99 13:45:09
;;; while running on Publications Y2K Testbed from HOST6:/usr/lib/symbolics/eop-world-pub6-host6-990831.vlod
;;; with Open Genera 2.0, Genera 8.5, Logical Pathnames Translation Files NEWEST,
;;; Lock Simple 437.0, Version Control 405.0, Compare Merge 404.0, CLIM 72.0,
;;; Genera CLIM 72.0, PostScript CLIM 72.0, CLIM Documentation 72.0,
;;; Statice Runtime 466.1, Statice 466.0, Statice Browser 466.0,
;;; Statice Server 466.2, Statice Documentation 426.0, Joshua 237.3,
;;; Joshua Documentation 216.0, Image Substrate 440.4,
;;; Essential Image Substrate 433.0, Mailer 438.0, Showable Procedures 36.3,
;;; Binary Tree 34.0, Working LispM Mailer 8.0, Experimental HTTP Server 70.3,
;;; Experimental W3 Presentation System 8.0,
;;; Experimental CL-HTTP Server Interface 53.0,
;;; Experimental Symbolics Common Lisp Compatibility 4.0,
;;; Experimental Comlink Packages 6.0, Experimental Comlink Utilities 10.0,
;;; Experimental COMLINK Cryptography 2.0, Experimental Routing Taxonomy 9.0,
;;; Experimental COMLINK Database 11.7, Experimental Email Servers 12.0,
;;; Experimental Comlink Customized LispM Mailer 7.0,
;;; Experimental Dynamic Forms 14.0, Experimental Communications Linker Server 39.2,
;;; Experimental Lambda Information Retrieval System 22.0,
;;; Experimental Comlink Documentation Utilities 6.0,
;;; Experimental White House Publication System 25.6,
;;; Experimental WH Automatic Categorization System 15.5,
;;; 8-5-Genera-Local-Patches 1.0, 39-COMLINK-Local-Patches 1.11,
;;; Publications-Server-Local-Patches 1.4, Ivory Revision 5, VLM Debugger 329,
;;; Genera program 8.16, DEC OSF/1 V4.0 (Rev. 205),
;;; 1260x932 24-bit TRUE-COLOR X Screen HOST6:0.0 with 224 Genera fonts (DECWINDOWS Digital Equipment Corporation Digital UNIX V4.0 R1),
;;; Machine serial number 1719841853,
;;; Local flavor function patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;LOCAL-FLAVOR-FUNCTION-PATCH-MARK2),
;;; Get emb file host patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;GET-EMB-FILE-HOST-PATCH),
;;; Get mailer home location from namespace (from EOP:CONFIG;MAIL-SERVER;PATCHES;MAILER-ENVIRONMENT-PATCH),
;;; Consider internet-domain-name when matching names to file hosts (from EOP:CONFIG;MAIL-SERVER;PATCHES;PATHNAME-HOST-NAMEP-PATCH.LISP.2),
;;; Parse pathname patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;PARSE-PATHNAME-PATCH),
;;; Get internal event code patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;GET-INTERNAL-EVENT-CODE-PATCH),
;;; AutoLogin (from EOP:CONFIG;MAIL-SERVER;PATCHES;AUTO-LOGIN.LISP.1),
;;; Generate an error any time there domain system tries to create a bogus host object for the local host. (from EOP:CONFIG;MAIL-SERVER;PATCHES;DETECT-BOGUS-HOST.LISP.1),
;;; Set Mailer UID variables for current namespace. (from EOP:CONFIG;MAIL-SERVER;PATCHES;MAILER-UID.LISP.1),
;;; Provide Switch between EOP and MIT sources. (from EOP:CONFIG;MAIL-SERVER;PATCHES;MIT-SOURCE.LISP.1),
;;; Make FS:USER-HOMEDIR look in the namespace as one strategy. (from EOP:CONFIG;MAIL-SERVER;PATCHES;USER-HOMEDIR.LISP.2),
;;; Local uid patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;LOCAL-UID-PATCH),
;;; Statice log clear patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;STATICE-LOG-CLEAR-PATCH),
;;; Make compiled-function-spec-p of CLOS class symbol return NIL instead of erring (from EOP:CONFIG;MAIL-SERVER;PATCHES;COMPILED-FUNCTION-SPEC-P-PATCH.LISP.1),
;;; Improve mailer host parsing (from EOP:CONFIG;MAIL-SERVER;PATCHES;PARSE-MAILER-HOST-PATCH.LISP.1),
;;; Make native domain name host patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;MAKE-NATIVE-DOMAIN-NAME-HOST-PATCH.LISP.1),
;;; Domain query cname loop patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;DOMAIN-QUERY-CNAME-LOOP-PATCH.LISP.1),
;;; Increase disk wired wait timeout from 30 to 90 seconds (from DISTRIBUTION|DIS-EMB-HOST:/db/eop.sct/eop/config/mail-server/patches/disk-wait-90-patch.),
;;; Checkpoint command patch (from EOP:CONFIG;MAIL-SERVER;PATCHES;CHECKPOINT-COMMAND-PATCH.LISP.9),
;;; Domain Fixes (from CML:MAILER;DOMAIN-FIXES.LISP.33),
;;; Don't force in the mail-x host (from CML:MAILER;MAILBOX-FORMAT.LISP.24),
;;; Make Mailer More Robust (from CML:MAILER;MAILER-FIXES.LISP.15),
;;; Patch TCP hang on close when client drops connection. (from HTTP:LISPM;SERVER;TCP-PATCH-HANG-ON-CLOSE.LISP.10),
;;; Add CLIM presentation and text style format directives. (from FV:SCLC;FORMAT.LISP.20),
;;; Fix Statice Lossage (from CML:LISPM;STATICE-PATCH.LISP.3),
;;; Make update schema work on set-value attributes with accessor names (from CML:LISPM;STATICE-SET-VALUED-UPDATE.LISP.1),
;;; COMLINK Mailer Patches. (from CML:LISPM;MAILER-PATCH.LISP.107),
;;; Clim patches (from CML:DYNAMIC-FORMS;CLIM-PATCHES.LISP.48),
;;; Increase disk wired wait timeout from 30 to 900 seconds (from EOP:CONFIG;MAIL-SERVER;PATCHES;DISK-WAIT-900-PATCH.LISP.1),
;;; Tcp implementation error intsrumentation patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;TCP-IMPLEMENTATION-ERROR-INTSRUMENTATION-PATCH.LISP.NEWEST),
;;; Increase packet buffers patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;INCREASE-PACKET-BUFFERS-PATCH.LISP.NEWEST),
;;; Close tcb patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;CLOSE-TCB-PATCH),
;;; Get output segment patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;GET-OUTPUT-SEGMENT-PATCH.LISP.NEWEST),
;;; Expansion buffer hack patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;EXPANSION-BUFFER-HACK-PATCH.LISP.1),
;;; Nfs directory list fast patch (from EOP:USERS;COMLINK;LOCAL-PATCHES;NFS-DIRECTORY-LIST-FAST-PATCH.LISP.NEWEST),
;;; Gc report patch (from EOP:MAIL-SERVER;PATCHES;GC-REPORT-PATCH.LISP.1),
;;; Pathname patch (from EOP:MAIL-SERVER;PATCHES;PATHNAME-PATCH.LISP.2),
;;; Pathname2 patch (from EOP:MAIL-SERVER;PATCHES;PATHNAME2-PATCH.LISP.3),
;;; Fix NFS brain damage. (from EOP:MAIL-SERVER;PATCHES;NFS-PATCH.LISP.8),
;;; Log patch (from EOP:MAIL-SERVER;PATCHES;LOG-PATCH.LISP.2),
;;; Vlm namespace append patch (from EOP:MAIL-SERVER;PATCHES;VLM-NAMESPACE-APPEND-PATCH.LISP.7),
;;; Bad rid error patch (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-1.LISP.1),
;;; Copy database patch (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-2.LISP.1),
;;; Cml bulk mail patch (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-6.LISP.1),
;;; Encode integer date patch (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-7.LISP.1),
;;; Fix year 199,
;;; from silly browsers (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-8.LISP.1),
;;; Fix wddi obsolete references (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-9.LISP.1),
;;; Ccc sign document enable services (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-10.LISP.1),
;;; End date for wh pub default (from EOP:LOCAL-PATCHES;COMLINK;39;39-COMLINK-LOCAL-PATCHES-1-11.LISP.2),
;;; Redirect to WWW.PUB.WHITEHOUSE.GOV (from EOP:PUB;HTTP;REDIRECT-TO-PRIMARY.LISP.12),
;;; Some holiday favorites for Pete (from EOP:LOCAL-PATCHES;PUBLICATIONS;PUBLICATIONS-SERVER-LOCAL-PATCHES-1-4.LISP.2).




(SCT:FILES-PATCHED-IN-THIS-PATCH-FILE 
  "HTTP:LAMBDA-IR;BIN-DUMP-UTILS.LISP.50"
  "HTTP:LAMBDA-IR;BIN-DUMP-UTILS.LISP.51")


;========================
(SCT:BEGIN-PATCH-SECTION)
(SCT:PATCH-SECTION-SOURCE-FILE "HTTP:LAMBDA-IR;BIN-DUMP-UTILS.LISP.50")
(SCT:PATCH-SECTION-ATTRIBUTES
  "-*- Package: lambda-ir; Mode: LISP; Syntax: Common-lisp; Base: 10 -*-")

(eval-when (compile eval load)
  (SCL:FUNDEFINE 'SAVE-IMAGE))

(defgeneric save-image (document-universe pathname &optional estimated-file-size)
  (:documentation "Dumps a binary image of DOCUMENT-UNIVERSE to PATHNAME, after sparsifying."))


;========================
(SCT:BEGIN-PATCH-SECTION)
(SCT:PATCH-SECTION-SOURCE-FILE "HTTP:LAMBDA-IR;BIN-DUMP-UTILS.LISP.50")
(SCT:PATCH-SECTION-ATTRIBUTES
  "-*- Package: lambda-ir; Mode: LISP; Syntax: Common-lisp; Base: 10 -*-")

(defmethod save-image ((document-universe document-universe) pathname &optional estimated-file-size)
  (sparsify-document-universe document-universe)
  (dump-one document-universe pathname estimated-file-size))


;========================
(SCT:BEGIN-PATCH-SECTION)
(SCT:PATCH-SECTION-SOURCE-FILE "HTTP:LAMBDA-IR;BIN-DUMP-UTILS.LISP.51")
(SCT:PATCH-SECTION-ATTRIBUTES
  "-*- Package: lambda-ir; Mode: LISP; Syntax: Common-lisp; Base: 10 -*-")

(defun read-one (filename &key (hash-table-test #'equalp))
  (declare (values object version))
  (with-open-file (str filename :direction :input :element-type '(unsigned-byte 8))
    (let ((version (read-byte str))
	  (*default-hash-table-test* hash-table-test)
	  (object (read-thing str))
	  (end-tag? (read-byte str)))
      (if (eq end-tag? +end-tag+)
	  (values object version)
	  (error "File corrupted or saved improperly; end-tag not found.")))))


;========================
(SCT:BEGIN-PATCH-SECTION)
(SCT:PATCH-SECTION-SOURCE-FILE "HTTP:LAMBDA-IR;BIN-DUMP-UTILS.LISP.51")
(SCT:PATCH-SECTION-ATTRIBUTES
  "-*- Package: lambda-ir; Mode: LISP; Syntax: Common-lisp; Base: 10 -*-")

(defgeneric load-image (pathname)
  (declare (values document-universe version.))
  (:documentation "Loads a saved-binary image of DOCUMENT-UNIVERSE from PATHNAME."))

