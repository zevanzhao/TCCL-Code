!Time-stamp: <Last updated: zevan zevan.zhao@gmail.com 2012-08-30 12:56:00>
!A simple Hartree-Fock progrm using sto-3G basis set
!This is an exercise of Fortran and the Hartree-Fock theory.
!Program is based on Szabo, A and Ostlund N S,
!Modern Quantum Chemistry: Introduction to advanced Electronic Structure Theory.
!The main program.
program main
  use numz
  real(8),external :: S, TK, V, F0, TWOE
  integer :: i,j,k,l
  print *,"*********************Two electron Hartree-Fock program for HeH+ *************"
  do i = 1,2
     print *, "Nuclear Charge: ",ZN(i), "at", R(i) ,"with Zeta" ,zeta(i)
  end do
  call ScaleCoeff()
  call FormMatrix()
  call SCF()
end program main

module numz
  real(8), parameter :: pi = 3.141592653589793239D0
  real(8), parameter :: coeff(3) = (/0.444635D0, 0.535328D0, 0.154329D0/)
  real(8), parameter :: expon(3) = (/0.109818D0, 0.405771D0, 2.22766D0/)
  !The following 3 lines control the geometry and property of the molecule.
  !R: coordinate of two atoms
  !Zeta: the sto-3g zeta value for He and H atom.
  !ZN: the charge of He and H
  !If you want to do calculation of H2, zeta(2) = (/1.24D0, 1.24D0/), ZN= (/1.0D0, 1.0D0/)
  real(8) :: R(2) = (/0.0D0, 1.4632D0/)
  real(8) :: Zeta(2) = (/2.0925D0,1.24D0/)
  real(8) :: ZN(2) = (/2.0D0,1.0D0/)
  integer :: MAXIT = 20
  real(8) :: CRIT = 1.0D-6
  !Al,De: scaled exponatial and coefficients of sto-3G Basis
  !SS: overlap matrix
  !T:kinetic matrix
  !TT: two-electron integrals
  !VV: nuclear-attraction of two nuclear
  !G: G matrix, the two electron part of Fock matrix
  !HH: the H-core matrix. one electron part of Fock matrix
  !PP: the density matrix P
  !F: fock matrix
  !FPrime: F'= X^{T}FX,
  !CC: coefficient matrix of basis.
  !Cprime: F'C' = C'E
  !XM: the transform matrix X = U*Sdiag^{-1/2}
  !XMT: the transposed XM
  !Sdiag: the diagnized overlap matrix.
  !ElectronEnergy: the total ElectronEnergy
  !TotalEnergy: the TotalEnergy, TotalEnergy = ElectronEnergy + Nuclear-repulsion energy
  !EORB: the orbital energies
  real(8) :: al(2,3),DE(2,3),SS(2,2),T(2,2), TT(2,2,2,2),VV(2,2,2),G(2,2),HH(2,2), PP(2,2)
  real(8) :: F(2,2), FPrime(2,2), CC(2,2), CPrime(2,2),XM(2,2),XMT(2,2),SDIAG(2,2)
  real(8) :: ElectronEnergy,TotalEnergy, EORB(2)
end module numz

!Calculate all the scaled coefficient of the basis
subroutine ScaleCoeff()
  use numz
  integer :: i,j
  print *,"scaling the basis set coefficients."
  do i = 1, 2
     do j = 1, 3
        al(i, j) = (zeta(i)**2)*expon(j)
        DE(i, j) = ((2.0D0*Al(i, j)/pi)**0.75D0)*coeff(j)
     end do
  end do
  do i = 1,2
     print *,"Basis exponents of function ", i
     print *,AL(i,:)
     print *,"Basis coefficients of function ", i
     print *,DE(i,:)
  end do
end subroutine ScaleCoeff

!Form the real overlap matrix Suv
subroutine FormMatrix()
  use numz
  integer :: u, v, p, q, j, i, k, l
  real(8):: S,TK,VA,TWOE,E(2),UM(2,2),VVA(2,2),VVB(2,2)
  !Initialize the matrix.
  do u = 1,2
     do v = 1,2
        if (u == v ) then 
           SS(u, v) = 1.0D0
        else
           SS(u, v) = 0.0D0
        end if
     end do
  end do
  T = 0.0D0
  TT = 0.0D0
  VV = 0.0D0
  XM = 0.0D0
  SDIAG = 0.0D0
  !calculate matrix element of one-electron integrals
  !overlap matrix and kinetic matrix
  do u = 1, 2
     do v = 1, 2
        do p = 1, 3
           do q = 1, 3
              if ( u <= v)  then
                 T(u, v) = T(u, v) + DE(u, p)*DE(v, q)*TK(Al(u, p),Al(v, q),R(u),R(v))
                 if (u < v) then 
                    SS(u, v) = SS(1, 2) + DE(u, p)*DE(v, q)*S(Al(u, p),Al(v, q),R(u),R(v))
                 end if
              else
                 T(u, v) = T(v, u)
                 SS(u, v) = SS(v, u)
              end if
           end do
        end do
     end do
  end do
  call matout("Overlap matrix", 2, 2, SS, 2)
  call matout("Kinetic matrix", 2, 2, T, 2)
  !nuclear attraction matrix. This function acts a little weird.
  do i = 1,2
     do u = 1,2
        do v = 1,2
           do p = 1,3
              do q = 1,3
                 VV(i, u, v) = VV(i, u, v) + DE(u,p)*DE(v,q)*VA(Al(u, p), Al(v, q), R(u), R(v), R(i),ZN(i))
              end do
           end do
        end do
     end do
  end do
  do i = 1,2
     do j = 1,2
        VVA(i,j) = VV(1,i,j)
        VVB(i,j) = VV(2,i,j)
     end do
  end do
  call matout("Nuclear Attraction matrix 1", 2,2,VVA,2)
  call matout("Nuclear Attraction matrix 2", 2,2,VVB,2)
!  print *,VV
  !Do the two electron integrals, in a very inefficient way.
  do p = 1, 2
     do q = 1, 2
        do u = 1, 2
           do v = 1, 2
              do i = 1, 3
                 do j = 1,3
                    do k = 1, 3
                       do l = 1,3
                          TT(p, q, u, v) = TT(p, q, u, v) + DE(p,i)*DE(q,j)*DE(u,k)*DE(v,l)&
                               *TWOE(Al(p,i),Al(q,j),Al(u,k),Al(v,l),R(p),R(q),R(u),R(v))
                       end do
                    end do
                 end do
              end do
           end do
        end do
     end do
  end do
  print *,"Two electron integrals: "
  do i = 1,2
     do j = 1,2
        do k = 1,2
           do l = 1,2
              print *,"(",i," ",j," ",k," ",l,")",TT(i,j,k,l)
           end do
        end do
     end do
  end do
  !Form the H matrix
  do i = 1, 2
     do j = 1, 2
        HH(i,j) = T(i,j) + VV(1,i,j) + VV(2,i,j)
     end do
  end do
  call matout("H-core matrix", 2, 2, HH, 2)
  call diag(SS, UM,E)
  do i = 1,2
     SDIAG(i,i) = 1/dsqrt(E(i))
  end do
  XM = matmul(UM, sdiag)
  call matout("X matrix", 2, 2, XM, 2)
  XMT = transpose(XM)
  call matout("X' matrix", 2, 2, XMT, 2)
end subroutine FormMatrix

!The most important SCF subroutine
subroutine SCF()
  use numz
  integer :: i,j,k,iteration
  real(8) :: GetElectronEnergy, olde, ediff
  print *,"***************************Start the SCF calculation**************"
  !initialize the P matrix. This is an "empty" initial guess.
  PP = 0.0D0
  call matout("P matrix",2, 2, PP, 2)
  do  iteration = 1, MAXIT
     print *, "************************Start of SCF Step ", iteration, "****************"
     !initialze the G matrix using P.
     call formg()
     call matout("G matrix",2, 2, G, 2)
     !Get the fock matrix
     F = HH + G
     call matout("F matrix",2, 2, F, 2)
     !get the electronic energy
     ElectronEnergy = GetElectronEnergy(PP, HH, F)
     print *,"ElectronEnergy(a.u.):",ElectronEnergy
     FPrime = matmul(matmul(XMT,F),XM)
     call matout("F' matrix",2, 2, FPrime, 2)
     !Get C' by diagnize F'. Orbital energy is also obtained.
     call diag(FPrime, CPrime, EORB)
     call matout("C' matrix",2, 2, CPrime, 2)
     print *,"Orbital Energy: ", EORB
     !Get C by C = XC'
     CC = matmul(XM, CPrime)
     call matout("C matrix",2, 2, CC, 2)
     !Update the density matrix P
     PP = 0.0D0
     do i = 1,2
        do j = 1,2
           do k = 1,1
              !Note that only one orbital is occupied (by two electrons).
              PP(i,j) = PP(i,j) + 2.0D0*CC(i,k)*CC(j,k)
           end do
        end do
     end do
     olde = ElectronEnergy
     ElectronEnergy= GetElectronEnergy(PP, HH, F)
     ediff = ElectronEnergy - olde
     print *,"New ElectronEnergy(a.u.):",ElectronEnergy
     print *,"SCF Step ", iteration, "Ediff ", Ediff
     if (abs(ediff) < crit) then
        print *, "Energy converged."
        exit
     end if
     end do
     print *,"ElectronEnergy(a.u.):", ElectronEnergy
     TotalEnergy = ElectronEnergy + ZN(1)*ZN(2)/(R(2)-R(1))
     print *,"TotalEnergy(a.u.):", TotalEnergy
     print *, "*****************************The End**********************************"
end subroutine SCF

!overlap matrix
real(8) function S(A, B, RA, RB)
  use numz
  real(8) :: A, B, RA,RB
  real(8) :: RAB2
  RAB2 = (RB - RA)*(RB - RA)
  S = (PI/(A + B))**1.5D0*dexp(-A*B*RAB2/(A + B))
  return
end function S

!kinetic energy integral of Gaussian function at center RA and RB
!Using RAB as a variable instead of RAB2, since RAB need to be calculated each time.
!More time consuming, but the code would be more clear
real(8) function TK(A, B, RA, RB)
  use numz
  real(8) :: A, B, RA, RB
  real(8) :: RAB2
  RAB2 = (RA - RB)*(RA - RB)
  TK = A*B/(A + B)*(3.00D0 - 2.00D0*A*B*RAB2/(A + B))*(PI/(A + B))**1.50*dexp(-A*B*RAB2/(A+B))
  return
end function TK

!Nuclear attraction integral
!two Gaussian function of exponet A and B at RA, RB and one nuclear of charge ZC at RC
real(8) function VA(A, B, RA, RB, RC, ZC)
  use numz
  real(8) :: A, B, RA, RB, RC, ZC
  real(8) ::  RAB, RAB2, RP,RCP, RCP2,F0
  RP = (A*RA + B*RB)/(A+B)
  RCP = (RC - RP)
  RAB = RB - RA
  RAB2 = RAB*RAB
  RCP2 = RCP*RCP
  VA = -2.0D0*PI*ZC/(A + B)*F0((A + B)*RCP2)*dexp(-A*B*RAB2/(A + B))
  return
end function VA

!F0 function
real(8) function F0(x)
  use numz
  real(8) :: x
  if (x < 1.0D-6) then 
     F0 = 1.0D0 - x/3.00D0
  else
     F0 = dsqrt(PI/x)*derf(dsqrt(x))/2.00D0
  end if
  return
end function F0

!two-electron integral
!four Gaussian functions of exponent A, B, C and D at center RA, RB, RC and RD.
real(8) function TWOE(A, B, C, D, RA, RB, RC, RD)
  use numz
  real(8) :: A, B, C, D, RA, RB, RC, RD
  real(8) :: RAB2, RCD2, RP, RQ, RPQ2,F0
  RAB2 = (RA - RB) * (RA - RB)
  RCD2 = (RC - RD)*(RC - RD)
  RP = (A*RA + B*RB)/(A + B)
  RQ = (C*RC + D*RD)/(C + D)
  RPQ2 = (RP - RQ)*(RP - RQ)
  TWOE = 2.0D0*(PI**2.5D0)/((A + B)*(C + D)* dsqrt(A + B + C + D))*F0((A + B)* (C + D)* RPQ2/(A + B + C + D))*&
  dexp(-A*B*RAB2/(A + B) - C*D*RCD2/(C + D))
  return
end function TWOE

!A subroutine to calculate the electron energy according to the matrix
real(8) function GetElectronEnergy(PM,HM, FM)
  use numz
  real(8) :: PM(2,2), HM(2,2), FM(2,2), EE
  integer :: i,j
  EE = 0.0D0
  do i = 1,2
     do j = 1,2
        EE = EE + 0.5D0*PM(i, j)* (HM(i,j) + FM(i,j))
     end do
  end do
  GetElectronEnergy = EE
  return 
end function GetElectronEnergy

!Print matrices of size M x N
subroutine matout(desc, M, N, MA, LDA )
  character *(*) ::    desc
  integer ::     M, N, LDA
  real(8)::  MA( LDA, * )
  integer :: I, J
  write(*,*)
  write(*,*) desc
  do I = 1, M
     write(*,9998) ( MA( I, J ), J = 1, N )
  end do
9998 format( 11(:,1X,F10.6) )
  return
end  subroutine matout

!diagonalize a matrix. Here using lapack is a better idea.
!diagonalize F to give eigenvectors in C and eigenvalues in E.
!F and C are of dimension 2
subroutine diag(F, C, E)
  real(8) :: F(2,2), C(2,2), E(2), work(8)
  integer:: l, inf
  C = F
  l = 8
  call dsyev('V','U',2, C, 2, E, work,l,inf)
end subroutine diag

!Form the G matrix 
subroutine formg()
  use numz
  integer :: i, j, k,l
  G = 0.0D0
  do i = 1,2
     do j = 1,2
        do k = 1,2
           do l= 1,2
              G(i,j) = G(i,j) + PP(k, l)* (TT(i,j,k,l) - 0.5D0*TT(i, l, k, j))
           end do
        end do
     end do
  end do
  return
end subroutine
