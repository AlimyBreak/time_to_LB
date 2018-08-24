      SUBROUTINE RECALC(IYR,IDAY,IHOUR,MIN,ISEC)
      
C  PREPARES ELEMENTS OF ROTATION MATRICES FOR TRANSFORMATIONS OF VECTORS BETWEEN
C  SEVERAL COORDINATE SYSTEMS, MOST FREQUENTLY USED IN SPACE PHYSICS.
C
C  THIS SUBROUTINE SHOULD BE INVOKED BEFORE USING THE FOLLOWING SUBROUTINES:
C         GEOGSM, MAGSM, SMGSM, GSMGSE, GEIGEO.
C
C  THERE IS NO NEED TO REPEATEDLY INVOKE RECALC, IF MULTIPLE CALCULATIONS ARE MADE
C    FOR THE SAME DATE AND TIME.
C
C-----INPUT PARAMETERS:

C     IYR   -  YEAR NUMBER (FOUR DIGITS)
C     IDAY  -  DAY OF YEAR (DAY 1 = JAN 1)
C     IHOUR -  HOUR OF DAY (00 TO 23)
C     MIN   -  MINUTE OF HOUR (00 TO 59)
C     ISEC  -  SECONDS OF MINUTE (00 TO 59)
C
C-----OUTPUT PARAMETERS:   NONE (ALL OUTPUT QUANTITIES ARE PLACED
C                                 INTO THE COMMON BLOCK /GEOPACK/)
C
C    OTHER SUBROUTINES CALLED BY THIS ONE: SUN
C
C   ################################################
C   #  WRITTEN BY  N.A. TSYGANENKO ON DEC.1, 1991  #
C   ################################################
c
c    Last modification:  January 5, 2001.
c    The code has been modified to accept dates through 2005.
c    Also, a "save" statement was added, to avoid potential problems
c    with some Fortran compilers.
C
      COMMON /GEOPACK/ ST0,CT0,SL0,CL0,CTCL,STCL,CTSL,STSL,SFI,CFI,SPS
      COMMON /GEOPACK/ CPS,SHI,CHI,HI,PSI,XMUT,A11,A21,A31,A12,A22,A32,A13,A23,A33,DS3
      COMMON /GEOPACK/  K,IY,CGST,SGST,BA(6)
c
      SAVE IYE,IDE,IPR
      DATA IYE,IDE,IPR/3*0/
C
      IF (IYR.EQ.IYE.AND.IDAY.EQ.IDE) GOTO 5
C
C   IYE AND IDE ARE THE CURRENT VALUES OF YEAR AND DAY NUMBER
C
      IY=IYR
      IDE=IDAY
      IF(IY.LT.1965) IY=1965
      IF(IY.GT.2005) IY=2005
C
C  WE ARE RESTRICTED BY THE INTERVAL 1965-2005,
C  FOR WHICH THE IGRF COEFFICIENTS ARE KNOWN; IF IYR IS OUTSIDE THIS INTERVAL
C  THE SUBROUTINE PRINTS A WARNING (BUT DOES NOT REPEAT IT AT NEXT INVOCATIONS)
C
      IF(IY.NE.IYR.AND.IPR.EQ.0) WRITE (*,10) IYR,IY
      IF(IY.NE.IYR) IPR=1
      IYE=IY
C
C  LINEAR INTERPOLATION OF THE GEODIPOLE MOMENT COMPONENTS BETWEEN THE
C  VALUES FOR THE NEAREST EPOCHS:
C
      IF (IY.LT.1970) THEN                            !1965-1970
        F2=(FLOAT(IY)+FLOAT(IDAY)/365.-1965.)/5.
        F1=1.D0-F2
           G10=30334.*F1+30220.*F2 ! HERE G10 HAS OPPOSITE SIGN TO THAT IN IGRF TABLES
        G11=-2119.*F1-2068.*F2
        H11=5776.*F1+5737.*F2
      ELSEIF (IY.LT.1975) THEN                        !1970-1975
        F2=(FLOAT(IY)+FLOAT(IDAY)/365.-1970.)/5.
        F1=1.D0-F2
           G10=30220.*F1+30100.*F2 ! HERE G10 HAS OPPOSITE SIGN TO THAT IN IGRF TABLES
        G11=-2068.*F1-2013.*F2
        H11=5737.*F1+5675.*F2
      ELSEIF (IY.LT.1980) THEN                        !1975-1980
        F2=(DFLOAT(IY)+DFLOAT(IDAY)/365.-1975.)/5.
        F1=1.D0-F2
           G10=30100.*F1+29992.*F2 ! HERE G10 HAS OPPOSITE SIGN TO THAT IN IGRF TABLES
        G11=-2013.*F1-1956.*F2
        H11=5675.*F1+5604.*F2
      ELSEIF (IY.LT.1985) THEN                        !1980-1985
        F2=(FLOAT(IY)+FLOAT(IDAY)/365.-1980.)/5.
        F1=1.D0-F2
           G10=29992.*F1+29873.*F2 ! HERE G10 HAS OPPOSITE SIGN TO THAT IN IGRF TABLES
        G11=-1956.*F1-1905.*F2
        H11=5604.*F1+5500.*F2
      ELSEIF (IY.LT.1990) THEN!1985-1990
        F2=(FLOAT(IY)+FLOAT(IDAY)/365.-1985.)/5.
        F1=1.D0-F2
           G10=29873.*F1+29775.*F2 ! HERE G10 HAS OPPOSITE SIGN TO THAT IN IGRF TABLES
        G11=-1905.*F1-1848.*F2
        H11=5500.*F1+5406.*F2
      ELSEIF (IY.LT.1995) THEN!1990-1995
        F2=(FLOAT(IY)+FLOAT(IDAY)/365.-1990.)/5.
        F1=1.D0-F2
           G10=29775.*F1+29682.*F2 ! HERE G10 HAS OPPOSITE SIGN TO THAT IN IGRF TABLES
        G11=-1848.*F1-1789.*F2
        H11=5406.*F1+5318.*F2
      ELSEIF (IY.LT.2000) THEN                        !1995-2000
        F2=(FLOAT(IY)+FLOAT(IDAY)/365.-1995.)/5.
        F1=1.D0-F2
        G10=29682.*F1+29615.*F2 ! HERE G10 HAS OPPOSITE SIGN TO THAT IN IGRF TABLES
        G11=-1789.*F1-1728.*F2
        H11=5318.*F1+5186.*F2
      ELSE                                            !2000-2005
C
C   LINEAR EXTRAPOLATION BEYOND 2000 BY USING SECULAR VELOCITY COEFFICIENTS:
C
        DT=FLOAT(IY)+FLOAT(IDAY)/366.-2000.
        G10=29615.-14.6*DT      ! HERE G10 HAS OPPOSITE SIGN TO THAT IN IGRF TABLES
        G11=-1728.+10.7*DT
        H11=5186.-22.5*DT
      ENDIF
C
C  NOW CALCULATE THE COMPONENTS OF THE UNIT VECTOR EzMAG IN GEO COORD.SYSTEM:
C   SIN(TETA0)*COS(LAMBDA0), SIN(TETA0)*SIN(LAMBDA0), AND COS(TETA0)
C         ST0 * CL0                ST0 * SL0                CT0
C
      SQ=G11**2+H11**2
      SQQ=SQRT(SQ)
      SQR=SQRT(G10**2+SQ)
      SL0=-H11/SQQ
      CL0=-G11/SQQ
      ST0=SQQ/SQR
      CT0=G10/SQR
      STCL=ST0*CL0
      STSL=ST0*SL0
      CTSL=CT0*SL0
      CTCL=CT0*CL0
C
C      THE CALCULATIONS ARE TERMINATED IF ONLY GEO-MAG TRANSFORMATION
C       IS TO BE DONE  (IHOUR>24 IS THE AGREED INDICATOR FOR THIS CASE):
C
5     IF (IHOUR.GT.24) RETURN
C
      CALL SUN(IY,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC)
C
C  S1,S2, AND S3 ARE THE COMPONENTS OF THE UNIT VECTOR EXGSM=EXGSE IN THE
C   SYSTEM GEI POINTING FROM THE EARTH'S CENTER TO THE SUN:
C
      S1=COS(SRASN)*COS(SDEC)
      S2=SIN(SRASN)*COS(SDEC)
      S3=SIN(SDEC)
      CGST=COS(GST)
      SGST=SIN(GST)
C
C  DIP1, DIP2, AND DIP3 ARE THE COMPONENTS OF THE UNIT VECTOR EZSM=EZMAG
C   IN THE SYSTEM GEI:
C
      DIP1=STCL*CGST-STSL*SGST
      DIP2=STCL*SGST+STSL*CGST
      DIP3=CT0
C
C  NOW CALCULATE THE COMPONENTS OF THE UNIT VECTOR EYGSM IN THE SYSTEM GEI
C   BY TAKING THE VECTOR PRODUCT D x S AND NORMALIZING IT TO UNIT LENGTH:
C
      Y1=DIP2*S3-DIP3*S2
      Y2=DIP3*S1-DIP1*S3
      Y3=DIP1*S2-DIP2*S1
      Y=SQRT(Y1*Y1+Y2*Y2+Y3*Y3)
      Y1=Y1/Y
      Y2=Y2/Y
      Y3=Y3/Y
C
C   THEN IN THE GEI SYSTEM THE UNIT VECTOR Z = EZGSM = EXGSM x EYGSM = S x Y
C    HAS THE COMPONENTS:
C
      Z1=S2*Y3-S3*Y2
      Z2=S3*Y1-S1*Y3
      Z3=S1*Y2-S2*Y1
C
C    THE VECTOR EZGSE (HERE DZ) IN GEI HAS THE COMPONENTS (0,-SIN(DELTA),
C     COS(DELTA)) = (0.,-0.397823,0.917462); HERE DELTA = 23.44214 DEG FOR
C   THE EPOCH 1978 (SEE THE BOOK BY GUREVICH OR OTHER ASTRONOMICAL HANDBOOKS).
C    HERE THE MOST ACCURATE TIME-DEPENDENT FORMULA IS USED:
C
      DJ=FLOAT(365*(IY-1900)+(IY-1901)/4 +IDAY)-0.5+
     &   FLOAT(IHOUR*3600+MIN*60+ISEC)/86400.
      T=DJ/36525.
      OBLIQ=(23.45229-0.0130125*T)/57.2957795
      DZ1=0.
      DZ2=-SIN(OBLIQ)
      DZ3=COS(OBLIQ)
C
C  THEN THE UNIT VECTOR EYGSE IN GEI SYSTEM IS THE VECTOR PRODUCT DZ x S :
C
      DY1=DZ2*S3-DZ3*S2
      DY2=DZ3*S1-DZ1*S3
      DY3=DZ1*S2-DZ2*S1
C
C   THE ELEMENTS OF THE MATRIX GSE TO GSM ARE THE SCALAR PRODUCTS:
C   CHI=EM22=(EYGSM,EYGSE), SHI=EM23=(EYGSM,EZGSE), EM32=(EZGSM,EYGSE)=-EM23,
C     AND EM33=(EZGSM,EZGSE)=EM22
C
      CHI=Y1*DY1+Y2*DY2+Y3*DY3
      SHI=Y1*DZ1+Y2*DZ2+Y3*DZ3
      HI=ASIN(SHI)
C
C    TILT ANGLE: PSI=ARCSIN(DIP,EXGSM)
C
      SPS=DIP1*S1+DIP2*S2+DIP3*S3
      CPS=SQRT(1.-SPS**2)
      PSI=ASIN(SPS)
C
C    THE ELEMENTS OF THE MATRIX MAG TO SM ARE THE SCALAR PRODUCTS:
C CFI=GM22=(EYSM,EYMAG), SFI=GM23=(EYSM,EXMAG); THEY CAN BE DERIVED AS FOLLOWS:
C
C IN GEO THE VECTORS EXMAG AND EYMAG HAVE THE COMPONENTS (CT0*CL0,CT0*SL0,-ST0)
C  AND (-SL0,CL0,0), RESPECTIVELY.    HENCE, IN GEI THE COMPONENTS ARE:
C  EXMAG:    CT0*CL0*COS(GST)-CT0*SL0*SIN(GST)
C            CT0*CL0*SIN(GST)+CT0*SL0*COS(GST)
C            -ST0
C  EYMAG:    -SL0*COS(GST)-CL0*SIN(GST)
C            -SL0*SIN(GST)+CL0*COS(GST)
C             0
C  THE COMPONENTS OF EYSM IN GEI WERE FOUND ABOVE AS Y1, Y2, AND Y3;
C  NOW WE ONLY HAVE TO COMBINE THE QUANTITIES INTO SCALAR PRODUCTS:
C
      EXMAGX=CT0*(CL0*CGST-SL0*SGST)
      EXMAGY=CT0*(CL0*SGST+SL0*CGST)
      EXMAGZ=-ST0
      EYMAGX=-(SL0*CGST+CL0*SGST)
      EYMAGY=-(SL0*SGST-CL0*CGST)
      CFI=Y1*EYMAGX+Y2*EYMAGY
      SFI=Y1*EXMAGX+Y2*EXMAGY+Y3*EXMAGZ
C
      XMUT=(ATAN2(SFI,CFI)+3.1415926536)*3.8197186342
C
C  THE ELEMENTS OF THE MATRIX GEO TO GSM ARE THE SCALAR PRODUCTS:
C
C   A11=(EXGEO,EXGSM), A12=(EYGEO,EXGSM), A13=(EZGEO,EXGSM),
C   A21=(EXGEO,EYGSM), A22=(EYGEO,EYGSM), A23=(EZGEO,EYGSM),
C   A31=(EXGEO,EZGSM), A32=(EYGEO,EZGSM), A33=(EZGEO,EZGSM),
C
C   ALL THE UNIT VECTORS IN BRACKETS ARE ALREADY DEFINED IN GEI:
C
C  EXGEO=(CGST,SGST,0), EYGEO=(-SGST,CGST,0), EZGEO=(0,0,1)
C  EXGSM=(S1,S2,S3),  EYGSM=(Y1,Y2,Y3),   EZGSM=(Z1,Z2,Z3)
C                                                           AND  THEREFORE:
C
      A11=S1*CGST+S2*SGST
      A12=-S1*SGST+S2*CGST
      A13=S3
      A21=Y1*CGST+Y2*SGST
      A22=-Y1*SGST+Y2*CGST
      A23=Y3
      A31=Z1*CGST+Z2*SGST
      A32=-Z1*SGST+Z2*CGST
      A33=Z3
C
10    FORMAT('*YEAR IS OUT OF INTERVAL 1965-2005: IYR=',
     & I4,'CALCULATIONS WILL BE DONE FOR IYR=',I4,/)
      RETURN
      END

C----------------------------------------------------------------------------
      SUBROUTINE GEOMAG(XGEO,YGEO,ZGEO,XMAG,YMAG,ZMAG,J,IYR)
C
C    CONVERTS GEOGRAPHIC (GEO) TO DIPOLE (MAG) COORDINATES OR VICA VERSA.
C    IYR IS YEAR NUMBER (FOUR DIGITS).
C
C                           J >  0                J < 0
C-----INPUT:  J,XGEO,YGEO,ZGEO,IYR   J,XMAG,YMAG,ZMAG,IYR
C-----OUTPUT:    XMAG,YMAG,ZMAG        XGEO,YGEO,ZGEO
C
C   OTHER SUBROUTINES CALLED BY THIS ONE:  RECALC
C
C   LAST MOFIFICATION:  JAN 5, 2001 (NO ESSENTIAL CHANGES, BUT
C                         SOME REDUNDANT STATEMENTS TAKEN OUT)
C
C   WRITTEN BY:  N. A. TSYGANENKO
C
      REAL XGEO,YGEO,ZGEO,XMAG,YMAG,ZMAG,IYR
      INTEGER J
      COMMON /GEOPACK/ ST0,CT0,SL0,CL0,CTCL,STCL,CTSL,STSL,AB(19),K,IY,BB(8)
      SAVE II
      DATA II/1/
C
      IF(IYR.EQ.II) GOTO 1
      II=IYR
      CALL RECALC(II,0,25,0,0)
1     CONTINUE
      IF(J.LT.0) GOTO 2
      XMAG=XGEO*CTCL+YGEO*CTSL-ZGEO*ST0
      YMAG=YGEO*CL0-XGEO*SL0
      ZMAG=XGEO*STCL+YGEO*STSL+ZGEO*CT0
      RETURN
2     XGEO=XMAG*CTCL-YMAG*SL0+ZMAG*STCL
      YGEO=XMAG*CTSL+YMAG*CL0+ZMAG*STSL
      ZGEO=ZMAG*CT0-XMAG*ST0
      RETURN
      END
c

C---------------------------------------------------------------------------

      SUBROUTINE SUN(IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC)
C
C  CALCULATES FOUR QUANTITIES NECESSARY FOR COORDINATE TRANSFORMATIONS
C  WHICH DEPEND ON SUN POSITION (AND, HENCE, ON UNIVERSAL TIME AND SEASON)
C
C-------  INPUT PARAMETERS:
C  IYR,IDAY,IHOUR,MIN,ISEC -  YEAR, DAY, AND UNIVERSAL TIME IN HOURS, MINUTES,
C    AND SECONDS  (IDAY=1 CORRESPONDS TO JANUARY 1).
C
C-------  OUTPUT PARAMETERS:
C  GST - GREENWICH MEAN SIDEREAL TIME, SLONG - LONGITUDE ALONG ECLIPTIC
C  SRASN - RIGHT ASCENSION,  SDEC - DECLINATION  OF THE SUN (RADIANS)
C  ORIGINAL VERSION OF THIS SUBROUTINE HAS BEEN COMPILED FROM:
C  RUSSELL, C.T., COSMIC ELECTRODYNAMICS, 1971, V.2, PP.184-196.
C
C     LAST MODIFICATION:  JAN 5, 2001 (NO ESSENTIAL CHANGES, BUT
C     SOME REDUNDANT STATEMENTS TAKEN OUT FROM THE PREVIOUS VERSION)
C
C     ORIGINAL VERSION WRITTEN BY:    Gilbert D. Mead
C
      DOUBLE PRECISION DJ,FDAY
      DATA RAD/57.295779513/
C
      IF(IYR.LT.1901.OR.IYR.GT.2099) RETURN
      FDAY=DFLOAT(IHOUR*3600+MIN*60+ISEC)/86400.D0
      DJ=365*(IYR-1900)+(IYR-1901)/4+IDAY-0.5D0+FDAY
      T=DJ/36525.
      VL=DMOD(279.696678+0.9856473354*DJ,360.D0)
      GST=DMOD(279.690983+.9856473354*DJ+360.*FDAY+180.,360.D0)/RAD
      G=DMOD(358.475845+0.985600267*DJ,360.D0)/RAD
      SLONG=(VL+(1.91946-0.004789*T)*SIN(G)+0.020094*SIN(2.*G))/RAD
      IF(SLONG.GT.6.2831853) SLONG=SLONG-6.2831853
      IF (SLONG.LT.0.) SLONG=SLONG+6.2831853
      OBLIQ=(23.45229-0.0130125*T)/RAD
      SOB=SIN(OBLIQ)
      SLP=SLONG-9.924E-5
C
C   THE LAST CONSTANT IS A CORRECTION FOR THE ANGULAR ABERRATION  DUE TO
C   THE ORBITAL MOTION OF THE EARTH
C
      SIND=SOB*SIN(SLP)
      COSD=SQRT(1.-SIND**2)
      SC=SIND/COSD
      SDEC=ATAN(SC)
      SRASN=3.141592654-ATAN2(COS(OBLIQ)/SOB*SC,-COS(SLP)/COSD)
      RETURN
      END
      
C------------------------------------------------------------------------
      SUBROUTINE SPHCAR(R,TETA,PHI,X,Y,Z,J)
C
C   CONVERTS SPHERICAL COORDS INTO CARTESIAN ONES AND VICA VERSA
C    (TETA AND PHI IN RADIANS).
C
C                  J > 0            J < 0
C-----INPUT:   J,R,TETA,PHI     J,X,Y,Z
C----OUTPUT:      X,Y,Z        R,TETA,PHI
C
C   LAST MOFIFICATION:  JAN 5, 2001 (NO ESSENTIAL CHANGES, BUT
C                        SOME REDUNDANT STATEMENTS TAKEN OUT)
C
C   WRITTEN BY:  N. A. TSYGANENKO
C
      REAL R,TETA,PHI,X,Y,Z
      INTEGER J
      
      IF(J.GT.0) GOTO 3
      SQ=X**2+Y**2
      R=SQRT(SQ+Z**2)
      IF (SQ.NE.0.) GOTO 2
      PHI=0.
      IF (Z.LT.0.) GOTO 1
      TETA=0.
      RETURN
1     TETA=3.141592654
      RETURN
2     SQ=SQRT(SQ)
      PHI=ATAN2(Y,X)
      TETA=ATAN2(SQ,Z)
      IF (PHI.LT.0.) PHI=PHI+6.28318531
      RETURN
3     SQ=R*SIN(TETA)
      X=SQ*COS(PHI)
      Y=SQ*SIN(PHI)
      Z=R*COS(TETA)
      RETURN
      END
