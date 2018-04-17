/* checkbat.c
 *
 * This file is part of checkbat
 *
 * Copyright(C) 2018 Jason Miller
 *
 * http://www.wanderinghuman.com/blog
 * or
 * http://www.wanderinghuman.com/
 *
 * This is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Library General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define    GENERIC_BUFF_SIZE   (5*1024) // 5k


static void Usage();
static int GetValAfterName(const char * buff, size_t buffsize, char ** lpsz, const char * name, size_t nAfterEqual);
static int RunIOREG(char* buff, size_t size, const char * cmd);

static void Usage(){
   printf("Usage:\n");
   printf("checkbat\n");
   printf("...");
   printf("checkbat -v for verbose\n");
   printf("THE END\n");
}

static int GetValAfterName(const char * buff, size_t buffsize, char ** lpsz, const char * name, size_t nAfterEqual){
   char * p;

   p = strstr(buff, name);

   if( !p ){
      return 1;
   }
   p = strchr(p, '=');
   if( !p ){
      return 2;
   }
   p += nAfterEqual;
   if( p - buff >= buffsize ){

      return 3;
   }
   *lpsz = p;
   return 0;
}

static int RunIOREG(char* buff, size_t size, const char * cmd){
   FILE * fp = popen(cmd, "r");
   int nRet = 1;
   if( fp ){
      const char * lpsz;
      
      // assumed they zeroed all bytes
      if( fgets(buff, size, fp) == NULL ){
         nRet = 2;
      }else{
         nRet = 0;
      }
      fclose( fp );
   }
   return nRet;

}

int main(int argc, char * argv[]){

   char * buff;

   if( argc > 2 ){
      Usage();
      exit(1);
   }

   if( argc > 1 && (strlen(argv[1]) != 2 || memcmp((void *)argv[1], (void *)"-v", 2) != 0) ){
      Usage();
      exit(1);
   }
   buff = (char *)malloc(GENERIC_BUFF_SIZE);
   if( buff ){
      unsigned int  nCapacity, nCurrent;
      const char * cmd;
      char * lpsz;

      memset((void *)buff, 0, GENERIC_BUFF_SIZE);
      nCurrent = nCapacity = -1;
      cmd = "ioreg -l | grep Capacity |  tr \'\\n\' \' | \'";
      if( !RunIOREG(buff, GENERIC_BUFF_SIZE, cmd) ){
         if( !GetValAfterName(buff, GENERIC_BUFF_SIZE, &lpsz, "\"CurrentCapacity\"", 2) ){
            nCurrent = atoi(lpsz);
            if( !GetValAfterName(buff, GENERIC_BUFF_SIZE, &lpsz, "\"MaxCapacity\" ", 2) ){
               nCapacity = atoi(lpsz);
               printf("Battery Level is %d%%\n", (((nCurrent*1000) / nCapacity)+5)/10);
               if( argc > 1 ){
                  printf("Current Capacity is: %d\n", nCurrent);
                  printf("Maximum Capacity is: %d\n", nCapacity);
               }
            }else{
               printf("Failed to parse battery capacity data\n");
            }
         }else{
            printf("Failed to parse current battery data\n");
         }
         
      }else{
         printf("Failed to process ioreg\n");
      }
      free( buff );
   }else{
      printf("Failed to allocate memory\n");
   }
   return 0;
}
