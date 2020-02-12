**free
Ctl-opt nomain PGMINFO(*PCML:*MODULE:*DCLCASE)
        COPYRIGHT('5770SS1 (C) Copyright IBM Corp. 2015, 2015. All rights +
                   reserved. US Government Users Restricted Rights - Use, +
                   duplication or disclosure restricted by GSA ADP Schedule +
                   Contract with IBM Corp. Licensed Materials-Property of IBM');

// -------------------------------------------------------------------
// LICENSE AND DISCLAIMER
// ----------------------
// This material contains IBM copyrighted sample programming source
// code ( Sample Code ).
// IBM grants you a nonexclusive license to compile, link, execute,
// display, reproduce, distribute and prepare derivative works of
// this Sample Code.  The Sample Code has not been thoroughly
// tested under all conditions.  IBM, therefore, does not guarantee
// or imply its reliability, serviceability, or function. IBM
// provides no program services for the Sample Code.
//
// All Sample Code contained herein is provided to you "AS IS"
// without any warranties of any kind. THE IMPLIED WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NON-INFRINGMENT ARE EXPRESSLY DISCLAIMED.
// SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED
// WARRANTIES, SO THE ABOVE EXCLUSIONS MAY NOT APPLY TO YOU.  IN NO
// EVENT WILL IBM BE LIABLE TO ANY PARTY FOR ANY DIRECT, INDIRECT,
// SPECIAL OR OTHER CONSEQUENTIAL DAMAGES FOR ANY USE OF THE SAMPLE
// CODE INCLUDING, WITHOUT LIMITATION, ANY LOST PROFITS, BUSINESS
// INTERRUPTION, LOSS OF PROGRAMS OR OTHER DATA ON YOUR INFORMATION
// HANDLING SYSTEM OR OTHERWISE, EVEN IF WE ARE EXPRESSLY ADVISED OF
// THE POSSIBILITY OF SUCH DAMAGES.
//
// -------------------------------------------------------------------
//  <START_COPYRIGHT>
//
//  Licensed Materials - Property of IBM
//
//  5770-SS1
//
//  (c) Copyright IBM Corp. 2015, 2015
//  All Rights Reserved
//
//  U.S. Government Users Restricted Rights - use,
//  duplication or disclosure restricted by GSA
//  ADP Schedule Contract with IBM Corp.
//
//  Status: Version 1 Release 0
//  <END_COPYRIGHT>
//
// -------------------------------------------------------------------
//  TO CREATE SERVICE PROGRAM:
//  (1) Database file STUDENTRSC/STUDENTDB needs to be created
//      via following 2 SQL statments:
//       CREATE TABLE STUDENTRSC/STUDENTDB
//        ("Student ID"  FOR COLUMN studentID CHAR (9) NOT NULL,
//         "First Name"  FOR COLUMN firstName CHAR (50) NOT NULL,
//         "last Name"   FOR COLUMN lastName  CHAR (50) NOT NULL,
//         "Gender Type" FOR COLUMN gender CHAR (10) NOT NULL,
//         PRIMARY KEY ( studentID ))
//        RCDFMT studentr
//
//       INSERT INTO STUDENTRSC/STUDENTDB
//        (studentID, firstName, lastName, gender)
//         VALUES('823M934LA', 'Nadir', 'Amra', 'Male'),
//               ('826M660CF', 'John', 'Doe', 'Male'),
//               ('747F023ZX', 'Jane', 'Amra', 'Female')
//
//   (2)  ADDLIBLE STUDENTRSC
//   (3)  CRTRPGMOD MODULE(STUDENTRSC/STUDENTRSC)
//                  SRCSTMF('/studentrsc.rpgle')
//   (4)  CRTSRVPGM SRVPGM(STUDENTRSC/STUDENTRSC) EXPORT(*ALL)
//
// -------------------------------------------------------------------
Dcl-f STUDENTDB USAGE(*UPDATE:*OUTPUT:*DELETE) KEYED USROPN;

Dcl-c H_OK const(200);
Dcl-c H_CREATED const(201);
Dcl-c H_NOCONTENT const(204);
Dcl-c H_BADREQUEST const(400);
Dcl-c H_NOTFOUND const(404);
Dcl-c H_CONFLICT const(409);
Dcl-c H_GONE const(410);
Dcl-c H_SERVERERROR const(500);
Dcl-c ERR_DUPLICATE_WRITE const(01021);

Dcl-ds studentRec qualified template;
  studentID char(9);
  firstName char(50);
  lastName char(50);
  gender char(10);
End-ds;

Dcl-pr openStudentDB int(10) End-pr;

Dcl-pr closeStudentDB int(10) End-pr;

Dcl-pr getAll;
  students_LENGTH int(10);
  students likeds(studentRec) dim(1000) options(*varsize);
  httpStatus  int(10);
  httpHeaders char(100) dim(10);
End-pr;

Dcl-pr getByID;
  studentID char(9) const;
  student likeds(studentRec);
  httpStatus int(10);
  httpHeaders char(100) dim(10);
End-pr;

Dcl-pr create;
  student likeds(studentRec);
  httpStatus int(10);
  httpHeaders char(100) dim(10);
End-pr;

Dcl-pr update;
  student likeds(studentRec);
  httpStatus int(10);
End-pr;

Dcl-pr remove;
  studentID char(9) const;
  httpStatus int(10);
End-pr;

//---------------------------------------------------------------
// Open file                                                    -
//---------------------------------------------------------------
Dcl-proc openStudentDB;
  Dcl-pi *N;
    *N int(10);
  End-pi;

  if Not %open(STUDENTDB);
    open(e) STUDENTDB;
    if %error;
      return 0;
    ENDIF;
  ENDIF;

  return 1;
End-proc;

//---------------------------------------------------------------
// closeStudentDB                                               -
//---------------------------------------------------------------
Dcl-Proc closeStudentDB;
  Dcl-pi *N int(10) End-pi;

  if %open(STUDENTDB);
    close(e) STUDENTDB;
    if %error;
      return 0;
    endif;
  endif;

  return 1;
End-proc;

//---------------------------------------------------------------
// getAll                                                       -
//---------------------------------------------------------------
Dcl-proc getAll export;
  Dcl-pi *N;
    students_LENGTH int(10);
    students likeds(studentRec) dim(1000) options(*varsize);
    httpStatus int(10);
    httpHeaders char(100) dim(10);
  End-pi;

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
End-proc;

//---------------------------------------------------------------
// getByID                                                      -
//---------------------------------------------------------------
Dcl-proc getByID export;
  Dcl-pi *N;
    studentID char(9) const;
    student likeds(studentRec);
    httpStatus int(10);
    httpHeaders char(100) dim(10);
  End-pi;

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
End-proc;

//---------------------------------------------------------------
// create                                                       -
//---------------------------------------------------------------
Dcl-proc create export;
  Dcl-pi *N;
    student likeds(studentRec);
    httpStatus int(10);
    httpHeaders char(100) dim(10);
  End-pi;
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
End-proc;

//---------------------------------------------------------------
// update                                                       -
//---------------------------------------------------------------
Dcl-proc update export;
  Dcl-pi *N;
    student likeds(studentRec);
    httpStatus int(10);
  End-pi;

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
End-proc;

//---------------------------------------------------------------
// remove                                                       -
//---------------------------------------------------------------
Dcl-proc remove export;
  Dcl-pi *N;
    studentID char(9) const;
    httpStatus int(10);
  End-pi;
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
End-proc;

