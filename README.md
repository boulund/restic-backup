# monolith-restic
Restic backup configuration for Monolith.

## Overview 
This configuration runs Restic to backup data from Monolith, a Linux server
running Debian, to a backup respository stored on Backblaze B2. Private
parameters are stored in a local file on the server, with user permissons only
for the root user. The required parameters are:

* `B2_ACCOUNT_ID` - Backblaze App Key ID
* `B2_ACCOUNT_KEY` - Backblaze App Key 
* `RESTIC_REPO_PASSWORD` - Password used to initalize Restic repo

The shell script that runs Restic to perform the backup will read the Backblaze
credentials from the file and export them as environment variables for Restic.
Restic reads the repo password from the file using the `--password-file`
argument, so it must contain nothing else.

A small file, `common.sh`, contains configurable settings such as paths to
secret files, repo string, etc. This file is sourced by the init and backup
scripts.

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
root@monolith:~# restic version
restic 0.11.0 compiled with go1.15.3 on linux/amd64
```

### Secure the required credentials
1. Create a file with Backblaze account ID and key in `/root/.restic_b2account`, in the following format:
    ```
    export B2_ACCOUNT_ID="012345678910"
    export B2_ACCOUNT_KEY="qwertyasdfhzxcvnnbvczhgfdaytreq"
    ```
   Note that this will be sourced into the backup script, so it must be valid
   bash syntax. Set permissions to `600` to ensure no other users can read the
   file contents.
2. Create a file with encyption password in plaintext in
   `/root/.restic_password`, with permissions `600`. 

The script `initalize_restic_b2_repo.sh` initalizes the Backblaze B2 bucket as
a Restic repo according to the instructions in the [Restic
docs](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html#backblaze-b2).
It reads application keys and Restic repo password from the configuration files
created in the two steps above. The init script makes a quick check to see if a
repo already exists, so it should be idempotent and safe to accidentally run
again.


# Summary of deployment procedure
1. Install Restic
2. Clone repo to server, `git clone git@github.com:boulund/monolith-restic /root/monolith-restic`
3. Create a file with Backblaze account ID and key in `/root/.restic_b2account`, with permissions `600`
4. Create a file with encyption password in `/root/.restic_password`, with permissions `600`

Either execute `init_restic_b2_repo.sh` if you haven't already or try to
execute `restic_backup.sh`.  If everything seems to be working as intended,
install the cronjob by copying `restic.cron` to `/etc/cron.d/restic.cron`.


# Restoring files
Refer to the official docs on how to restore files:
https://restic.readthedocs.io/en/stable/050_restore.html

