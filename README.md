# \# checkbat for iPad Battery status

This is a simple command line executable to check the status of your iPad's battery

#### Requirements
  * Jailbroken iPad with SSH enabled
  * Terminal program or SSH program
  * Only tested on IOS 9.3.5 with iPad gen 3

[User Guide](userdoc/checkbatInfo.txt) has detailed info. Get to a terminal and do:

#### Command line options:
```
$ ./checkbat
or
$ ./checkbat -v
```

#### Screenshot
![checkbat screenshot][screenshot1]

#### Dependencies
* Jailbroken iPad
* C Compiler, libs, and headers [followed this, or similar](https://codingmachineboris.wordpress.com/2014/10/20/install-gcc-on-ios/)
* Have ldid and in your path, see above

#### Building
* Get the package sources
* `$ make` to make debug
* `$ make all` to make debug and release
* More options described in the top of the [Makefile](Makefile)

#### Package
* The packaged binary is available at [http://www.wanderinghuman.com/checkbat/](http://www.wanderinghuman.com/checkbat/)

#### License
 * GPL version 3 or (at your option) any later version

[screenshot1]:http://www.wanderinghuman.com/software/photos/blog/chkbat_ss.png "checkbat screenshot"
