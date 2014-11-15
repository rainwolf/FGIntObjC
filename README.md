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

- Feedback is always welcome.

- I have included an example for all 5 algorithms, the documentation consists of comments in the FGInt.m
and ECGFp.m files and the method names are fairly straightforward. I haven't added comments to the 
FGIntCryptography.m file, but that will change soon, again, the method names pretty much explain what they do.

Enjoy.

ToDo
====
* add support for Edwards curves
* add support for the OpenPGP standard. Soon.
* protection against side channel attacks.
