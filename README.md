# restic-backup
[Restic](https://restic.net/) backup wrapper configuration for Linux.

## Overview 
This configuration runs Restic to backup data from a Linux server, tested on
Debian, to a backup respository stored on Backblaze B2. Private parameters are
stored in local files on the server, with user permissons only for the root
user. The required parameters are:

* `RESTIC_REPOSITORY` - The remote repository restic should connect to
* `B2_ACCOUNT_ID` - Backblaze App Key ID
* `B2_ACCOUNT_KEY` - Backblaze App Key 
* Password used to initalize Restic repo, stored in a separate file.

The shell script that runs Restic to perform the backup will read the
`RESTIC_REPOSITORY` varible and Backblaze credentials from a file and export
them as environment variables for Restic.  Restic reads the repo password from
the file using the `--password-file` argument, so the password must be in its
own file and contain nothing else.

A small file, `common.sh`, contains configurable settings such as paths to
secret files, and which local paths that should be included and excluded from
the backup, etc. This file is sourced by the init and backup scripts.

NOTE: Running Restic as root is not recommended. Read the example in the [Restic
docs](https://restic.readthedocs.io/en/stable/080_examples.html#backing-up-your-system-without-running-restic-as-root)
for a way to run Restic as a separate system user instead.


## First-time setup
Install Restic using the precompiled binary. At the time of this writing it is: 
https://github.com/restic/restic/releases/download/v0.11.0/restic_0.11.0_linux_amd64.bz2

```
wget --output-document restic.bz2 https://github.com/restic/restic/releases/download/v0.11.0/restic_0.11.0_linux_amd64.bz2
bunzip2 restic.bz2
chmod +x restic
mv restic /usr/local/bin/
```

Verify that it works by running `restic version`:

```
# restic version
restic 0.11.0 compiled with go1.15.3 on linux/amd64
```

### Secure the required credentials
1. Create a file with Backblaze account ID and key in `/root/.restic_b2account`, in the following format:
    ```
    export RESTIC_REPOSITORY="b2:bucketname:dirname"
    export B2_ACCOUNT_ID="012345678910"
    export B2_ACCOUNT_KEY="qwertyasdfhzxcvnnbvczhgfdaytreq"
    ```
   Note that this will be sourced by bash into the backup script, so it must be
   valid bash syntax. Set permissions to `600` to ensure no other users can read
   the file contents.
2. Create a file with encyption password in plaintext in
   `/root/.restic_password`, with permissions `600`. 

`initalize_restic_b2_repo.sh` initalizes the Backblaze B2 bucket as a Restic
repo according to the instructions in the [Restic
docs](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html#backblaze-b2).
It reads application keys and Restic repo password from the configuration files
created in the two steps above. The init script makes a quick check to see if a
repo already exists, so it should be idempotent and safe to accidentally run
again. Double check the settings in `common.sh` before running the
initalization script.


## Automate backups
A small cronscript is included in the repo: `restic.cron`. Place a copy of this
in `/etc/cron.d/restic` (note the filename: it must not have an extension).


# Summary of deployment procedure
1. Install Restic
2. Clone repo to server, `git clone git@github.com:boulund/restic-backup /root/restic-backup`
3. Create a file with Restic repo string , Backblaze account ID and key in
   `/root/.restic_b2account`, with permissions `600`
4. Create a file with encyption password in `/root/.restic_password`, with permissions `600`

Either execute `init_restic_b2_repo.sh` if you haven't already or try to
execute `restic_backup.sh`.  If everything seems to be working as intended,
install the cronjob by copying `restic.cron` to `/etc/cron.d/restic`.


# Restoring files
Run `mount_repo.sh` to mount the remote B2 repo as a file system under `/mnt/restic`.

For more info on how to restore files, refer to the official docs:
https://restic.readthedocs.io/en/stable/050_restore.html


# Running arbitrary Restic commands
`restic.sh` can be used to simplify running arbitrary restic commands against
the preconfigured B2 repo. It reads the Backblaze B2 repo configuration and
associated password from the same configuration files as the other scripts in
this repo. Usage is easy, e.g.:

List all existing snapshots:
```
./restic.sh snaphots
```

The snapshot hashes listed can be used to see which files were included in the
last backup by comparing the two last snaphots with the `diff` command:
```
./restic.sh diff HASH1 HASH2
```

