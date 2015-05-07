License, info, etc
------------------
This implementation is made by me, Walied Othman, and you can contact by email at rainwolf@submanifold.be 

These are my first steps in Objective-C, as I wanted to learn the language, I decided to rewrite my 
old work (FGInt for FreePascal/Delphi) in Objective-C. FGInt stands for Fast Gigantic Integers. I 
wrote it using native Objective-C constructions like NSData and so on.

- The libraries have to be compiled separately when using ARC, I tried using it in the libraries but
that made it a bunch slower. It's always a good idea to compile them separately, and always using the
-O3 compiler option, the difference in speed is too big not to do it.

- I have implemented RSA, ElGamal, DSA, GOSTDSA, ECDSA and ECElGamal. Encryption for the 1st two and 
digital signatures for the 1st four, mind you that these are the raw algorithms, no hashing, checksums, 
... are included. 

- I've added support for the NIST curves and twisted Edwards curves. Ed25519-SHA-512 is fully implemented, there is no need to hash what you want to sign before signing.

- ~~There is some support for Curve25519 computations, but no pretty framework yet, I have to think that over.~~ I have implemented Salsa20, XSalsa20, Poly1305, Poly1305-AES, XSalsa20Poly1305, and added support for NaCl-like boxed packets.

- Feedback is always welcome.

- I have included an example for all algorithms, the documentation consists of comments in the FGInt.m
and ECGFp.m files and the method names are fairly straightforward. I haven't added comments to the 
FGIntCryptography.m file, but that will change soon, again, the method names pretty much explain what they do.

Enjoy.

ToDo
====
* add support for the OpenPGP standard. Soon.
* protection against side channel attacks.
* a cryptographically secure PRNG


License
=======
I'm licensing it under the GPLv3: https://www.gnu.org/licenses/gpl-3.0.html
until I find a better alternative. If you require a different license, contact me.
