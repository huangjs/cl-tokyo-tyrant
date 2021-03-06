(in-package "TOKYO-TYRANT")

;;; I referred some codes from the cl-pack library by Dan Ballard
;;; http://www.cliki.net/cl-pack

(defun pack-int (item size)
  (bytes-to-string (twos-complement item size) size))

(defun pack-N (item)
  "the pack function for 'N' as unsigned long 32bit integer by the big endian"
  (pack-int item 4))

(defun pack-Q (item)
  "the pack function for 'N' as unsigned quad 64bit integer by the big endian"
  (pack-int item 8))

;;; BIG ENDIAN
(defun bytes-to-string (bytes length)
  "puts length bytes from bytes into a string"
  (coerce (bytes-to-list bytes length) 'string))

(defun bytes-to-list (bytes length)
  "bytes:  Some binary data in lisp number form that ldb can access
  bytes-to-list pulls out 8bit bytes from bytes and turns them into
    their corresponding characters and returns the list of them"
  (loop for i from (- length 1) downto 0 collect (code-char (ldb (byte 8 (* 8 i)) bytes))))

(defun twos-complement (number max-size)
  (if (< number 0)
      (1+ (lognot (min (expt 2 (1- (* 8 max-size))) (abs number))))
      (min (1- (expt 2 (* 8 max-size))) number)))

(defun unpack-int (string size)
  (un-twos-complement (string-to-bytes string size) size))

(defun unpack-N (string)
  "the unpack function for 'N' as unsigned long 32bit integer by the big endian"
  (un-twos-complement (string-to-bytes string 4) 4))

(defun unpack-Q (string)
  "the unpack function for 'Q' as unsigned long 64bit integer by the big endian"
  (un-twos-complement (string-to-bytes string 8) 8))

;;; BIG ENDIAN
(defun string-to-bytes (string length)
  (unpack-bytes (reverse string) length))

(defun unpack-bytes (string length)
  "takes length bytes from string and returns an int"
  (let ((int 0))
    (loop for i from 0 to (1- length)
        do (setf (ldb (byte 8 (* 8  i)) int) (char-code (char string i))))
    int))

(defun un-twos-complement (number max-size)
  (if (>= number (expt 2 (1- (* 8 max-size))))
      (- number (expt 2 (* 8 max-size)))
      (min (expt 2 (1- (* 8 max-size))) number)))

(defun string-ascii (string &key (external-format nil))
  (multiple-value-bind (octets length) (string-to-octets string
                                                         :external-format (or external-format (locale-external-format *locale*))
                                                         :null-terminate nil)
    (values (octets-to-string octets :end length :external-format 'ascii)
            length)))

(defun string-external (string &key (external-format :utf8))
  (multiple-value-bind (octets length) (string-to-octets string
                                                         :external-format :ascii
                                                         :null-terminate nil)
    (values (octets-to-string octets :end length :external-format (or external-format (locale-external-format *locale*)))
            length)))

(defun hash-table-to-key-value-list (hash-table)
  "{key0: value0, key1: value1} -> (key0 value0 key1 value1)"
  (loop for key being the hash-key using (hash-value value) of hash-table
      append (list key value)))

(defun string-join-by-nullchar (&rest args)
  (format nil "~{~a~^ ~}" args))

(defun alist-to-hash-table (alist &key ((:test test) 'eql))
  (let ((table (make-hash-table :test test)))
    (dolist (p alist)
      (setf (gethash (car p) table) (cdr p)))
    table))
