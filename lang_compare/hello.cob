       IDENTIFICATION DIVISION.
       PROGRAM-ID. HelloWorld.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  HelloMessage  PIC X(25) VALUE 'Hello, World!'.

       PROCEDURE DIVISION.
           DISPLAY HelloMessage
           STOP RUN.
