;;; -*- Mode: LISP; Syntax: Common-Lisp; Package: USER; Base: 10; Patch-File: t -*-
;;; Patch file for HTTP-PROXY version 6.28
;;; Reason: Function HTTP::PROXY-CACHEABLE-REQUEST-HEADER-PLIST:  update for change in %with-header-set-index
;;; Written by JCMa, 11/06/01 15:28:57
;;; while running on FUJI-VLM from FUJI:/usr/lib/symbolics/ComLink-39-8-F-MIT-8-5.vlod
;;; with Open Genera 2.0, Genera 8.5, Lock Simple 437.0, Version Control 405.0,
;;; Compare Merge 404.0, VC Documentation 401.0,
;;; Logical Pathnames Translation Files NEWEST, CLIM 72.0, Genera CLIM 72.0,
;;; PostScript CLIM 72.0, MAC 414.0, 8-5-Patches 2.19, Statice Runtime 466.1,
;;; Statice 466.0, Statice Browser 466.0, Statice Documentation 426.0, Joshua 237.6,
;;; CLIM Documentation 72.0, Showable Procedures 36.3, Binary Tree 34.0,
;;; Mailer 438.0, Working LispM Mailer 8.0, HTTP Server 70.154,
;;; W3 Presentation System 8.1, CL-HTTP Server Interface 53.0,
;;; Symbolics Common Lisp Compatibility 4.0, Comlink Packages 6.0,
;;; Comlink Utilities 10.4, COMLINK Cryptography 2.0, Routing Taxonomy 9.0,
;;; COMLINK Database 11.26, Email Servers 12.0, Comlink Customized LispM Mailer 7.1,
;;; Dynamic Forms 14.5, Communications Linker Server 39.8,
;;; Lambda Information Retrieval System 22.5, Jcma 44,
;;; Experimental Genera 8 5 Patches 1.0, Genera 8 5 System Patches 1.39,
;;; Genera 8 5 Mailer Patches 1.1, Genera 8 5 Joshua Patches 1.0,
;;; Genera 8 5 Statice Runtime Patches 1.0, Genera 8 5 Statice Patches 1.0,
;;; Genera 8 5 Statice Server Patches 1.0,
;;; Genera 8 5 Statice Documentation Patches 1.0, Genera 8 5 Clim Patches 1.3,
;;; Genera 8 5 Genera Clim Patches 1.0, Genera 8 5 Postscript Clim Patches 1.0,
;;; Genera 8 5 Clim Doc Patches 1.0, Genera 8 5 Lock Simple Patches 1.0,
;;; HTTP Proxy Server 6.27, HTTP Client Substrate 4.20, Statice Server 466.2,
;;; Ivory Revision 5, VLM Debugger 329, Genera program 8.16,
;;; DEC OSF/1 V4.0 (Rev. 110),
;;; 1280x994 8-bit PSEUDO-COLOR X Screen FUJI:0.0 with 224 Genera fonts (DECWINDOWS Digital Equipment Corporation Digital UNIX V4.0 R1),
;;; Machine serial number -2141189585,
;;; Domain Fixes (from CML:MAILER;DOMAIN-FIXES.LISP.33),
;;; Don't force in the mail-x host (from CML:MAILER;MAILBOX-FORMAT.LISP.24),
;;; Make Mailer More Robust (from CML:MAILER;MAILER-FIXES.LISP.15),
;;; Patch TCP hang on close when client drops connection. (from HTTP:LISPM;SERVER;TCP-PATCH-HANG-ON-CLOSE.LISP.10),
;;; Add CLIM presentation and text style format directives. (from FV:SCLC;FORMAT.LISP.20),
;;; Fix Statice Lossage (from CML:LISPM;STATICE-PATCH.LISP.3),
;;; Make update schema work on set-value attributes with accessor names (from CML:LISPM;STATICE-SET-VALUED-UPDATE.LISP.1),
;;; COMLINK Mailer Patches. (from CML:LISPM;MAILER-PATCH.LISP.107),
;;; Clim patches (from CML:DYNAMIC-FORMS;CLIM-PATCHES.LISP.48),
;;; Domain ad host patch (from W:>reti>domain-ad-host-patch.lisp.21),
;;; Background dns refreshing (from W:>reti>background-dns-refreshing.lisp.11),
;;; Cname level patch (from W:>Reti>cname-level-patch.lisp.10),
;;; Fix FTP Directory List for Periods in Directory Names (from W:>Reti>fix-ftp-directory-list.lisp.7),
;;; TCP-FTP-PARSE-REPLY signal a type error when control connection lost. (from W:>Reti>tcp-ftp-parse-reply-patch.lisp.1).



(SCT:FILES-PATCHED-IN-THIS-PATCH-FILE 
  "HTTP:PROXY;UTILS.LISP.82")


;========================
(SCT:BEGIN-PATCH-SECTION)
(SCT:PATCH-SECTION-SOURCE-FILE "HTTP:PROXY;UTILS.LISP.82")
(SCT:PATCH-SECTION-ATTRIBUTES
  "-*- Mode: LISP; Syntax: Ansi-common-lisp; Package: HTTP; Base: 10 -*-")

(defun proxy-cacheable-request-header-plist (header-set &optional include-headers exclude-headers )
  "Converts HEADER-SET into a property list of (keyword value).
Removes all connection-level, request-specific and user-specific headers.
EXCLUDE-HEADERS is a list of additional headers to suppress.
INCLUDE-HEADERS is a list of headers not to suppress, which overrides any other suppression mode."
  (flet ((collect-p (header-keyword header include-headers exclude-headers)
	   (and (cacheable-request-header-p header-keyword)
		(or (member header-keyword include-headers)
		    (not (or (member exclude-headers *user-specific-request-headers*)
			     (member exclude-headers exclude-headers)
			     (%header-suppress-p header)))))))
    (declare (inline collect-p))
    (%with-header-set-index (header-set)
      (with-fast-array-references ((headers .headers. vector)
				   (index index vector))
	(loop with header-value and parsing-error-p
	      for idx fixnum upfrom 0 below (fill-pointer headers)
	      for header = (aref headers idx)
	      for header-keyword = (aref index idx)
	      when (collect-p header-keyword header include-headers exclude-headers)
		do (multiple-value-setq (header-value parsing-error-p) (safe-header-value header))
		and unless parsing-error-p
		      collect header-keyword
		      and collect header-value)))))

