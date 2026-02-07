INSERT INTO ftpusers (username, password, uid, gid, homedir, shell)
VALUES (
  'carlos',
  CONCAT('{sha256}', TO_BASE64(UNHEX(SHA2('1234', 256)))),
  2001,
  2001,
  '/var/ftp/users/carlos',
  '/bin/false'
);
