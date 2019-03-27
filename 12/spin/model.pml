ltl specluz1{
[]((ligth_state==OFF&&(btn||press))->(<>ligth_state==ON))
}
ltl specluz2{
[]((ligth_state==ON)->(<>ligth_state==OFF))
}
ltl specalarm1{
[]((alarm_state==DISARMED&&code==correctcode)->(<>alarm_state==ARMED))
}
ltl specalarm2{
[]((alarm_state==ARMED&&code==correctcode)->(<>alarm_state==DISARMED))
}
ltl specodigo1{
[](btn2->(<>(cuentainc==cuenta+1)))
}
ltl specodigo2{
[]((timecode>timeoutcode&&cuenta==code1)->(<>(digit==0||digit==1||digit==2&&cuenta==0)))
}
ltl specodigo3{
[]((timecode>timeoutcode&&cuenta==code3)->(<>correct==1))
}

#define TIMEOUT 100
int correctcode= 321;
mtype={OFF,ON,ARMED,DISARMED,PASSWORD}
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
int code1;
int code2;
int code3;
int cuenta;
int digit;
int correct;
int btn2;

active proctype ligth(){
	ligth_state=OFF;
	do
	::(ligth_state==OFF)->atomic{
		if
		::(press||btn)->btn=0;press=0;ligth_state=ON;deadline=time + TIMEOUT;		
		fi
	}
	::(ligth_state==ON)->atomic{
		if
		::press->press=0;deadline=time + TIMEOUT;
		::(time>deadline)->ligth_state=OFF
		::!press->skip
		fi
	}
	od
}
active proctype alarm(){
	alarm_state=DISARMED;
	do
	::(alarm_state==ARMED)->atomic{
		if
		::(code==correctcode)-> alarm_state=DISARMED
		fi	
	}
	::(alarm_state==DISARMED)->atomic{
		if
		::(code==correctcode)-> alarm_state=ARMED
		fi	
	}
	od
}
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
active proctype entorno1(){
	time=0;
	do
	::if
	  ::btn=1
	  ::press=1
	  ::skip
	  fi
	  time=time+1;
	  printf("time=%d,state=%e,btn=%d,press=%d,deadline=%d\n",time,ligth_state,btn,press,deadline)
	od
}
active proctype entorno2(){
	do
	::if
	  ::code=234
	  ::code=123
	  ::code=431
	  ::code=789
	  ::code=321
	  ::code=111
	  ::code=273
	  ::code=481
	  ::code=503
	  ::code=626
	  ::code=333
	  ::code=456
	  ::code=619
	  ::code=832
	  ::code=900
	  ::code=304
	  ::code=507
	  ::code=670
	  ::code=897
	  ::code=9900
	  fi
	  printf("code=%d correctcode=%d\n",code,correctcode)
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
