debtap
======

A script for converting .deb packages into Arch Linux packages, focused on accuracy

# FAQ

**Q: What "debtap" stands for?**

**A:** DEB To Arch (Linux) Package

**Q: Isn't better to download an official package or write a PKGBUILD in case I need to compile a package or convert a .deb package to an Arch Linux package?**

**A:** Sure it is, and I truely encourage you to do so. Debtap was written to create packages that either cannot be compiled (closed source packages) or cannot be built from AUR for various reasons (error during compiling or unavailable files), as a quick 'n' dirty solution and an extra option for creating Arch Linux packages for Arch Linux users.

**Q: So debtap will help me only in case I need to convert specific .deb packages to Arch Linux packages?**

**A:** No. In case you need to write a new PKGBUILD for a package that already exists in the Debian/Ubuntu distributions, by converting its .deb package to Arch package with debtap, thanks to the packages names translator function inside the script, it can help you determine which dependencies are needed for the package you write the PKGBUILD for and complete the necessary fields.

**Q: What are the minimum requirements to run this script?**

**A:** You need to have installed these dependencies: `bash`, `binutils` (provides ar utility for extracting .deb package), `pkgfile` and `fakeroot`.You must run at least once (preferably recently) `debtap -u` to create/update pkgfile and debtap database (you do this with root privileges).

**Q: Debtap needs a lot of time to convert a package. So, why this is happening?**

**A:** Like I said, debtap is focused on accuracy. It won't just unpack a .deb package and then repackage its data to an Arch Linux package, ignoring metadata. Depending on the speed of your processor and the package itself, conversion can take from a few seconds to several minutes.

**Q: During conversion I get several warning messages, why?**

**A:** Debtap cannot be 100% accurate for several reasons,  the main reason for this is the complexity of packages names. If you want to check the freshly generated `.PKGINFO` and `.INSTALL` (this is optional file) metadata files or even fix the untranslated packages names inside `.PKGINFO`, debtap offers you the option to edit these files before compressing the final package.

**Q: How do I use debtap?**

**A:** The syntax is quite simple actually: `debtap [option] package_filename`
For example: `debtap world-of-goo-demo_1.0_i386.deb`

Any recommendations or questions for debtap are welcomed!
