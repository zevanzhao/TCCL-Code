### Makefile --- Make Hartree-Fock program

## Author: zevan.zhao@gmail.com
## Version: $Id: Makefile,v 0.0 2012/08/09 12:13:01 zevan Exp $
## Keywords: 
## X-URL: 
FC=gfortran
FFLAGS= -llapack -lblas
HF: HFCalc.o
	$(FC) -o hf HFCalc.o $(FFLAGS)
HFCalc.o: HFCalc.f90
	$(FC) -c HFCalc.f90
