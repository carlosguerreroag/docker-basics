INSERT INTO ftp_groups (group_name, gid, members)
VALUES
  ('ftpusers', 5500, 'carlos'),
  ('ftpusers', 5500, 'external');

INSERT INTO `ftp_users` (`user_name`, `password`, `home_directory`, `uid`, `gid`, `shell`)
VALUES
  ('carlos', ENCRYPT('1234'), '/home/ftpusers/carlos', 5500, 5500, '/sbin/nologin'),
  ('external', ENCRYPT('test'), '/home/ftpusers/external', 5500, 5500, '/sbin/nologin');
