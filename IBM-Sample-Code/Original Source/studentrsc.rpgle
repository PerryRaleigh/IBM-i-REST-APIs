     h NOMAIN PGMINFO(*PCML:*MODULE:*DCLCASE)
     h COPYRIGHT('+
     h 5770SS1 (C) Copyright IBM Corp. 2015, 2015. All rights +
     h reserved. US Government Users Restricted Rights - Use, duplication +
     h or disclosure restricted by GSA ADP Schedule Contract with +
     h IBM Corp. Licensed Materials-Property of IBM')
      *********************************************************************
      * LICENSE AND DISCLAIMER                                            *
      * ----------------------                                            *
      * This material contains IBM copyrighted sample programming source  *
      * code ( Sample Code ).                                             *
      * IBM grants you a nonexclusive license to compile, link, execute,  *
      * display, reproduce, distribute and prepare derivative works of    *
      * this Sample Code.  The Sample Code has not been thoroughly        *
      * tested under all conditions.  IBM, therefore, does not guarantee  *
      * or imply its reliability, serviceability, or function. IBM        *
      * provides no program services for the Sample Code.                 *
      *                                                                   *
      * All Sample Code contained herein is provided to you "AS IS"       *
      * without any warranties of any kind. THE IMPLIED WARRANTIES OF     *
      * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND             *
      * NON-INFRINGMENT ARE EXPRESSLY DISCLAIMED.                         *
      * SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED          *
      * WARRANTIES, SO THE ABOVE EXCLUSIONS MAY NOT APPLY TO YOU.  IN NO  *
      * EVENT WILL IBM BE LIABLE TO ANY PARTY FOR ANY DIRECT, INDIRECT,   *
      * SPECIAL OR OTHER CONSEQUENTIAL DAMAGES FOR ANY USE OF THE SAMPLE  *
      * CODE INCLUDING, WITHOUT LIMITATION, ANY LOST PROFITS, BUSINESS    *
      * INTERRUPTION, LOSS OF PROGRAMS OR OTHER DATA ON YOUR INFORMATION  *
      * HANDLING SYSTEM OR OTHERWISE, EVEN IF WE ARE EXPRESSLY ADVISED OF *
      * THE POSSIBILITY OF SUCH DAMAGES.                                  *
      *                                                                   *
      *  <START_COPYRIGHT>                                                *
      *                                                                   *
      *  Licensed Materials - Property of IBM                             *
      *                                                                   *
      *  5770-SS1                                                         *
      *                                                                   *
      *  (c) Copyright IBM Corp. 2015, 2015                               *
      *  All Rights Reserved                                              *
      *                                                                   *
      *  U.S. Government Users Restricted Rights - use,                   *
      *  duplication or disclosure restricted by GSA                      *
      *  ADP Schedule Contract with IBM Corp.                             *
      *                                                                   *
      *  Status: Version 1 Release 0                                      *
      *  <END_COPYRIGHT>                                                  *
      *                                                                   *
      *********************************************************************
      *  TO CREATE SERVICE PROGRAM:                                       *
      *  (1) Database file STUDENTRSC/STUDENTDB needs to be created       *
      *      via following 2 SQL statments:                               *
      *       CREATE TABLE STUDENTRSC/STUDENTDB                           *
      *        ("Student ID"  FOR COLUMN studentID CHAR (9) NOT NULL,     *
      *         "First Name"  FOR COLUMN firstName CHAR (50) NOT NULL,    *
      *         "last Name"   FOR COLUMN lastName  CHAR (50) NOT NULL,    *
      *         "Gender Type" FOR COLUMN gender CHAR (10) NOT NULL,       *
      *         PRIMARY KEY ( studentID ))                                *
      *        RCDFMT studentr                                            *
      *                                                                   *
      *       INSERT INTO STUDENTRSC/STUDENTDB                            *
      *        (studentID, firstName, lastName, gender)                   *
      *         VALUES('823M934LA', 'Nadir', 'Amra', 'Male'),             *
      *               ('826M660CF', 'John', 'Doe', 'Male'),               *
      *               ('747F023ZX', 'Jane', 'Amra', 'Female')                            *
      *                                                                   *
      *   (2)  ADDLIBLE STUDENTRSC                                        *
      *   (3)  CRTRPGMOD MODULE(STUDENTRSC/STUDENTRSC)                    *
      *                  SRCSTMF('/studentrsc.rpgle')                     *
      *   (4)  CRTSRVPGM SRVPGM(STUDENTRSC/STUDENTRSC) EXPORT(*ALL)       *
      *                                                                   *
      *                                                                   *
      *********************************************************************

     FSTUDENTDB UF A E           K DISK    USROPN

      /copy /studentpr.rpgleinc

       //***************************************************************
       // Open file                                                    *
       //***************************************************************
     P openStudentDB   B
     D openStudentDB   PI            10i 0
      /FREE
       if NOT %open(STUDENTDB);
         open(e) STUDENTDB;
         if %ERROR;
           return 0;
         endif;
       endif;

       return 1;
      /END-FREE
     P openStudentDB   E

       //***************************************************************
       // closeStudentDB                                               *
       //***************************************************************
     P closeStudentDB  B
     D closeStudentDB  PI            10i 0
      /FREE
       if %open(STUDENTDB);
         close(e) STUDENTDB;
         if %error;
           return 0;
         endif;
       endif;

       return 1;
      /END-FREE
     P closeStudentDB  E

       //***************************************************************
       // getAll                                                       *
       //***************************************************************
     P getAll          B                   EXPORT
     D getAll          PI
     D  students_...
     D  LENGTH                       10i 0
     D  students                           likeds(studentRec) dim(1000)
     D                                     options(*varsize)
     D  httpStatus                   10i 0
     D  httpHeaders                 100a   dim(10)
      /FREE
       clear httpHeaders;
       clear students;
       students_LENGTH = 0;

       openStudentDB();

       setll *loval STUDENTDB;

       read(e) studentR;
       if (%ERROR);
         httpStatus = H_SERVERERROR;
         return;
       endif;

       dow (NOT %eof);
         students_LENGTH = students_LENGTH+1;
         students(students_LENGTH).studentID =  studentID;
         students(students_LENGTH).firstName =  firstName;
         students(students_LENGTH).lastName  =  lastName;
         students(students_LENGTH).gender    =  gender;

         read(e) studentR;
         if (%ERROR);
           httpStatus = H_SERVERERROR;
           return;
         endif;
       enddo;

       httpStatus = H_OK;
       httpHeaders(1) = 'Cache-Control: no-cache, no-store';

       closeStudentDB();
      /END-FREE
     P getAll          E

       //***************************************************************
       // getByID                                                      *
       //***************************************************************
     P getByID         B                   EXPORT
     D getByID         PI
     D  studentID                     9a   const
     D  student                            likeds(studentRec)
     D  httpStatus                   10i 0
     D  httpHeaders                 100a   dim(10)
      /FREE
       clear httpHeaders;
       clear student;
       
       openStudentDB();

       chain(e) studentID STUDENTDB;
       if (%ERROR);
         httpStatus = H_SERVERERROR;
         return;
       elseif %FOUND;
         student.studentID = studentID;
         student.firstName = firstName;
         student.lastName  = lastName;
         student.gender    = gender;

         httpStatus = H_OK;
       else;
         httpStatus = H_NOTFOUND;
       endif;

       httpHeaders(1) = 'Cache-Control: no-cache, no-store';

       closeStudentDB();
      /END-FREE
     P getByID         E

       //***************************************************************
       // create                                                       *
       //***************************************************************
     P create          B                   EXPORT
     D create          PI        
     D  student                            likeds(studentRec)
     D  httpStatus                   10i 0
     D  httpHeaders                 100a   dim(10)
      /FREE
       openStudentDB();

       studentID = student.studentID;
       firstName = student.firstName;
       lastName  = student.lastName;
       gender    = student.gender;

       write(e) studentR;
       if NOT %ERROR;
         httpStatus = H_CREATED;
         // URL will need to change to your server and port
         httpHeaders(1) = 'Location: ' + 
                  'http://server:port/web/service/students/' + studentID;
       elseif %STATUS = ERR_DUPLICATE_WRITE;
         httpStatus = H_CONFLICT;
       else;
         httpStatus = H_SERVERERROR;
       endif;

       closeStudentDB();
      /END-FREE
     P create          E

       //***************************************************************
       // update                                                       *
       //***************************************************************
     P update          B                   EXPORT
     D update          PI   
     D  student                            likeds(studentRec)
     D  httpStatus                   10i 0
      /FREE
       openStudentDB();

       chain(e) student.studentID STUDENTDB;
       if (%ERROR);
         httpStatus = H_SERVERERROR;
         return;
       elseif %FOUND;
         studentID = student.studentID;
         firstName = student.firstName;
         lastName  = student.lastName;
         gender    = student.gender;

         update(e) studentR;
         if NOT %ERROR;
           httpStatus = H_NOCONTENT;
         else;
           httpStatus = H_NOTFOUND;
         endif;
       else;
         httpStatus = H_NOTFOUND;
       endif;

       closeStudentDB();
      /END-FREE
     P update          E

       //***************************************************************
       // remove                                                       *
       //***************************************************************
     P remove          B                   EXPORT
     D remove          PI    
     D  studentID                     9a   Const
     D  httpStatus                   10i 0
      /FREE
       openStudentDB();

       chain(e) studentID STUDENTDB;
       if (%ERROR);
         httpStatus = H_SERVERERROR;
         return;
       elseif %FOUND;
         delete(e) studentR;
         if NOT %ERROR;
           httpStatus = H_NOCONTENT;
         elseif NOT %FOUND;
           httpStatus = H_NOTFOUND;
         else;
           httpStatus = H_SERVERERROR;
         endif;
       else;
         httpStatus = H_NOTFOUND;
       endif;

       closeStudentDB();
      /END-FREE
     P remove          E
