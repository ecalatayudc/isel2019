ltl specodigo1{
[](btn2->(<>(cuentainc==cuenta+1)))
}
ltl specodigo2{
[]((timecode>timeoutcode&&cuenta==code1)->(<>(digit==0||digit==1||digit==2&&cuenta==0)))
}
ltl specodigo3{
[]((timecode>timeoutcode&&cuenta==code3)->(<>correct==1))
}
#define TIMEOUT 1

mtype={PASSWORD}
int ligth_state;
int alarm_state;
int code_state;
int btn;
int deadline;
int time;
int press;
int code;
int timecode;

int timeoutcode;
int code1=1;
int code2=2;
int code3=3;
int correctcode= code3*100+code2*10+code1;
int cuenta;
int digit;
int correct;
int btn2;
int cuentainc;
int codet;
active proctype codigo(){
	code_state==PASSWORD;	
	do
	::(code_state==PASSWORD)->atomic{
		if
	  	::(btn2)->btn2=0;cuentainc=cuenta;cuenta=cuenta+1;timeoutcode=timecode+TIMEOUT;
	  	::((timecode>timeoutcode)&&(code1==cuenta))->code_state=PASSWORD;digit=1;codet=cuenta;cuenta=0;correct=0;
		::((timecode>timeoutcode)&&(code2==cuenta))->code_state=PASSWORD;digit=2;codet=codet+cuenta*10;cuenta=0;correct=0;
		::((timecode>timeoutcode)&&(code3==cuenta))->code_state=PASSWORD;digit=0;codet=codet+cuenta*100;cuenta=0;correct=0;
		::((timecode>timeoutcode)&&(code1!=cuenta))->code_state=PASSWORD;digit=0;cuenta=0;correct=0;
		::((timecode>timeoutcode)&&(code2!=cuenta))->code_state=PASSWORD;digit=0;cuenta=0;correct=0;
		::((timecode>timeoutcode)&&(code3!=cuenta))->code_state=PASSWORD;digit=0;cuenta=0;correct=0;
		::(correctcode==codet)->code_state=PASSWORD;correct=1
		::!btn2->skip
	  	fi
	}
	od
}
active proctype entorno3(){
	timecode=0;
	do
	::if
	  ::(!btn2)->skip
	  ::btn2=1
	  fi
	  timecode=timecode+1;
	  printf("timeoutcode=%d,timecode=%d,btn2=%d,codet=%d,cuenta=%d,correct=%d,correctcode=%d,digit=%d\n",timeoutcode,timecode,btn2,codet,cuenta,correct,correctcode,digit)
	od
}
