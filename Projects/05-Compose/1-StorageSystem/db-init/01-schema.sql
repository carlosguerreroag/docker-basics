CREATE TABLE ftpusers (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- Auto-incrementing primary key
    username VARCHAR(255) NOT NULL,     -- Username, max length 255 characters
    password VARCHAR(255) NOT NULL,     -- Password, max length 255 characters
    uid INT NOT NULL,                   -- User ID, integer type
    gid INT NOT NULL,                   -- Group ID, integer type
    homedir VARCHAR(255) NOT NULL,      -- Home directory path, max length 255 characters
    shell VARCHAR(255) NOT NULL         -- Shell, max length 255 characters
);
