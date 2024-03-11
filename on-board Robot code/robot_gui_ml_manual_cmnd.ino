//code for the arduino MEGA board on the robot. 

/* mazouziabdou6@outlook.com */ 



#include <SPI.h>

#include <SharpIR.h>
#include "nRF24L01.h"
#include "RF24.h" 
#include <Servo.h>


Servo myservo1;
Servo myservo2;
int msg[2];
RF24 radio(48,49); //  CE CSN 
int mode[2]; 
int Smode = 0; 


///  les assign /// 

int red = 22 ; 
int blue  = 24 ; 
int ledmode =  26 ; 

SharpIR sensor( SharpIR::GP2Y0A41SK0F, A0 );


//Wheels 
int right_en = 2;//PWM
const int RB=3;
const int RF=4;
const int LB=5;
const int LF=6;
int left_en = 7;//PWM

const byte address[6] = "00001";

volatile int dis1 =  31 ; 
volatile char a = 0;
volatile int picked = 0;


void setup() {
  //servo setup
  myservo1.attach(8);
  myservo2.attach(9);
  
    for (int m = 20; m >= 5; m--) {
      myservo1.write(m);
      delay(15);
    }


  // put your setup code here, to run once:
  Serial.begin(9600);
  radio.begin();
  radio.openReadingPipe(0, address);
  radio.setPALevel(RF24_PA_MIN);
  radio.startListening();


  

pinMode(RF,OUTPUT);
pinMode(RB,OUTPUT);
pinMode(LF,OUTPUT);
pinMode(LB,OUTPUT);


pinMode(red,OUTPUT);
pinMode(blue,OUTPUT);
pinMode(ledmode,OUTPUT);  



}

void loop() {
  

if (radio.available()) {
   radio.read(msg,2);  
   //char a = mode[0]; 
  
      //Serial.println(msg[0]);
       //delay(300);
      //delay(200) ;
   switch (msg[0]) {
        case 'A' ://auto mode 
  Smode = 1 ;  

 
          
          break;
          
        case 'M' ://manual mode
        Smode = 2 ;  


    
          break;
  
  }   }


int dis1 = getdistance() ; 

if (Smode == 1){
 

if(picked==0){  


digitalWrite(red,HIGH);
digitalWrite(blue,LOW); 
   
if ( dis1 >= 13  ) {



              switch (msg[0]) {
        case 'F' ://front
          front();
          
          break;
          
        case 'R' ://right front
          rightf();
          break;

        case 'L' ://left front
          leftf();
          break;

        case 'N':
         randomrun();
         //STOP();
          break;
          
          case 'f':
          randomrun();
          break;

          case 'r':
          randomrun();
          break;

          case 'l':
          randomrun();
          break; 
         
      } 
}
 else if ( dis1 < 10) 
  {
     back();
    delay(50);
    STOP();
  }
   else if ( dis1 <= 13 && dis1 >= 10)
  { //pickup the object
   pickobject();
  }
  } // if picked == 0 


  else if(picked == 1){

    digitalWrite(blue,HIGH) ; 
    digitalWrite(red,LOW); 

  if (dis1 >= 12 ) {

     switch (msg[0]) {
        case 'f' ://front
          front();
          
          break;
          
        case 'r' ://right front
          rightf();
          break;

        case 'l' ://left front
          leftf();
          break;

        case 'N':
          randomrun();
          break;

         
      }
  } // dis1 >= 8 && picked ==1
      else if ( dis1 < 8) 
  {
    back();
    delay(50);
    STOP();
  }
  else if (picked == 1 && dis1 <= 12 && dis1 >= 8)
  { //stop when less than 12
   dropobject();
  }
}
      

//} /// radio   manual mode 
} // manual mode if smode == 1 ;  
else if (Smode == 2){

//if (radio.available()) {

    //  radio.read(msg,2);  
     // char a = msg[0];
      //Serial.println(a);
      //delay(1000) ;
       if ( dis1 >= 6) {
       
 
              switch (msg[0]) {
        case 'F' ://front

       
          front();
      

          
          break;
          
        case 'R' ://right front
          rightf();
     

          break;

        case 'L' ://left front
          leftf();
   

          break;

        case 'B':
         back();
  
       
          break;
           case 'S':
        
         STOP();
          break;  
                  case 'P':
          pickobject();
  picked = 0;
       
          break;
           case 'D':
        
         dropobject();
          break;  
         

         
      }
}

  else {
    
    back();
    delay(50);
    STOP();
    }


 

  
  } // automode if Smode == 2


} // loop




void front(){
//Serial.println("Forward Move");
digitalWrite(RF,HIGH);
digitalWrite(LF,HIGH);
digitalWrite(RB,LOW);
digitalWrite(LB,LOW);

  analogWrite(left_en, 160);
  analogWrite(right_en, 160);

delay(100);

}
void back(){
   // Serial.println("Back Move");
    digitalWrite(RB,HIGH);
    digitalWrite(LB,HIGH);
    digitalWrite(RF,LOW);
    digitalWrite(LF,LOW);
  analogWrite(left_en, 160);
  analogWrite(right_en, 160);

   delay(100);
 
}
void leftf(){
  digitalWrite(RF,HIGH);
  digitalWrite(RB,LOW);
  digitalWrite(LB,HIGH);
  digitalWrite(LF,LOW);
  analogWrite(left_en, 150);
  analogWrite(right_en, 150);
}
void rightf(){
  digitalWrite(LF,HIGH);
  digitalWrite(LB,LOW);
  digitalWrite(RF,LOW);
  digitalWrite(RB,HIGH);
  analogWrite(left_en, 150);
  analogWrite(right_en, 150);

  
}
void STOP(){
  digitalWrite(RF,LOW);
  digitalWrite(RB,LOW);
  digitalWrite(LF,LOW);
  digitalWrite(LB,LOW);
  analogWrite(left_en, 0);
  analogWrite(right_en, 0);
  delay(50);
  
}

void randomrun() {

  
    digitalWrite(RF,HIGH);
  digitalWrite(RB,LOW);
  digitalWrite(LF,LOW);
  digitalWrite(LB,HIGH);


   analogWrite(left_en, 140);
  analogWrite(right_en, 140);
  delay(100);
  
}


void pickobject()
{
   STOP();
   
   for (int k = 150; k > 70; k--) {
      myservo2.write(k);
      delay(15);
    }
delay(500);

    for (int k = 5; k < 90; k=k+2) {
      myservo1.write(k);
      delay(15);
    }

    delay(500);

   for (int j = 0; j < 145; j=j+2) {
      myservo2.write(j);
      delay(15);
    }
    delay(500);

    for (int m = 90; m >= 5; m--) {
      myservo1.write(m);
      delay(15);
    }
    delay(500);


    //up


   picked = 1;
      back();
    delay(100);
    STOP();
  }


  void dropobject(){

   STOP();

    for (int j = 5; j <=65; j++) {
      myservo1.write(j);
      delay(15);
    }
    delay(500);


    for (int k = 150; k > 70; k--) {
      myservo2.write(k);
      delay(15);
    }

    delay(500);

    for (int l = 65; l >= 5; l--) {
      myservo1.write(l);
      delay(20);
    }
    delay(500);


    picked = 0;
    //dropback();

     back();
    delay(150);
    STOP();
    
   // finish=1;
   // digitalWrite(32,1);//BUZZER sounds
    // delay(1000);
    //digitalWrite(32,0);
  }
int getdistance()
{
 int dis = sensor.getDistance(); //Calculate the distance in centimeters and store the value in a variable
delay(80);

 return dis ;
  
  }
