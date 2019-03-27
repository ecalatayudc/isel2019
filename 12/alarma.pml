ltl specalarm1{
[]((alarm_state==DISARMED&&code==correctcode)->(<>alarm_state==ARMED))
}
ltl specalarm2{
[]((alarm_state==ARMED&&code==correctcode)->(<>alarm_state==DISARMED))
}


#define TIMEOUT 100
int correctcode= 321;
mtype={ARMED,DISARMED}
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
