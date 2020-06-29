pts-xcom: DOS COM encoder for the Universal ASCII message

xcom.com converts a DOS COM executable file to an equivalent, self-decoding
COM file, with only ASCII bytes (codes 32..126) and CRLF (code 13, then 10).

If you speak Hungarian, see the description in xcom_hu.txt .

An explanation of how it could be done:
https://codegolf.stackexchange.com/a/155023/4483

Limitation: any changes of line breaks (e.g. from CRLF to LF) will break the
ASCII output of xcom.com. Unfortunately mail software and text editors often
do such changes.

A similar project with the same limitation: com4mail by Krasilnikov in 1993.
Executable com4mail.com is available from http://nozdr.ru/marinais/ :
http://nozdr.ru/marinais/texts/zip/com4mail.zip

A similar project which produces DOS EXE executables with only ASCII bytes:
https://www.cs.cmu.edu/~tom7/abc/paper.pdf . It also contains an explanation
of how it can be done.

A similar project which creates ASCII-only i386 machine code:
http://www.dmi.unipg.it/bista/didattica/sicurezza-pg/buffer-overrun/hacking-book/0x2a0-writing_shellcode.html

__END__
