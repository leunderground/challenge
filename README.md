# ssm-exercises

These exercises are part of the hiring process for the [Systems and Security Managers](www.safe2choose.org/job-opportunities). When you have finished, send an encrypted email to `tech@safe2choose.org`.

Part 0: Prepare environment
===========================
1. Create a Github account. Note that for privacy and security reasons, some of our staff do not use their personal Github accounts for safe2choose work. You may want to create a new Github account just for these exercises.
2. You will receive a ZIP file with the code.
3. Create a new repository on your account and add the unzipped files in the first commit.

Part 1: Code review
===================
Review the code in this repository for  security vulnerabilities.
This Meteor project is meant to keep track of the number of times each user clicks on the button on the client. The count per user is recorded in two places:
1. On the Meteor server that the app is connected to.
2. On a server located at `secure.safe2choose.org` (this server does not actually exist).

Only the counts of users who have signed in with Twitter need to be securely stored. The count of users who are not logged in is irrelevant.

Although this code will compile, it should be treated as pseudo-code.
Do not worry about inefficient or ugly code. You are only looking for vulnerabilities that would allow users to abuse the system or issues that would give hackers with access to the code the ability to compromise different parts of the system (assuming those components actually existed).

**Deliverable:** Add comments to this README with explanations of the vulnerabilities you are able to find. For extra points, correct the source code to fix those issues. When finished, commit your changes.

Part 2: Server setup
====================
Write a script that will setup a default WordPress installation and an IRC server. This script will be run on a fresh install of a Debian 8.5 x64 1GB droplet on Digital Ocean (NY 1 Data Region) as `root`. The script may leverage any tools you would like (eg Chef) or none at all.

After running the script, the WordPress website should be available from a browser and the IRC server should be accessible from a standard client. Do not forget to have the script setup any other security features necessary.

If you send an email to `tech@safe2choose.org` with your SSH key, we will give you access to a test droplet. Note that we will not look at the test droplet and you will only be evaluated against the script you write. You may use self signed certificates for the domain test.saf2choose.org as necessary.

**Deliverable:** Save this script as `deploy.sh` and commit it to your repository.
