ltl specluz1{
[]((ligth_state==OFF&&(btn||press))->(<>ligth_state==ON))
}
ltl specluz2{
[]((ligth_state==ON)->(<>ligth_state==OFF))
}
#define TIMEOUT 10
int correctcode= 321;
mtype={OFF,ON}
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
