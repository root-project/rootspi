Static Analysis for ROOT using Jenkins in SFT

Activating static analysis for the ROOT builds managed by jenkins is easy.
The idea is to launch clang via a wrapper which puts at the right place all the
necessary arguments to trigger SA. This wrapper is called clang(++) and its
actions are steered with environment variables, for example set up by 
jenkins or by jenkins launcher scripts.

