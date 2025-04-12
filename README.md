# Linux From Scratch

## Sources

- [Linux From Scratch 12.3](https://www.linuxfromscratch.org/lfs/view/stable/index.html)

## Instructions

- [Gentoo LiveGUI USB image](https://www.gentoo.org/downloads/) has been used as build host
- Set the correct keyboard layout on gentoo and thereafter open Konsole
- connect to internet
- clone [this](https://github.com/bengtbengtsson/lfs.git) repo into root's user gentoo home directory

```bash
sudo -i
cd /root
git clone https://github.com/bengtbengtsson/lfs.git scripts
```

- start in chapter 2, read the script file (it is all not clear!)

- the scripts are tested on a x86_64 computer

## Tests
Some of the tests run in chapter 8 will fail (this is unfortunate but expected)

### Known fails:

- glibc --> io/tst-faccessat-setui and io/tst-lchmod
- acl --> test/cp.test
- tar --> capabilities binary store/store
- e2fsprogs --> m_assure_storage_prezeroed

It is recommended to run all tests and when hitting test failure in one of the above scripts:

- comment out the make check | make test in the script file
- remove or comment out all scripts already built (in file build-ch08.sh)
- now you will have the failed script as the first script in the 'packages' list
- rm -rf /sources/< directory of failed test >
- restart the 'build-ch08.sh' script
