
extern void MainAsm(void);
extern void Delay2sec(void);
extern void Espera_Delay(void);
extern void ConfigReg(void);
extern void Liga_Motor(void);
extern void Desliga_Motor(void);
extern void Liga_Injetor(void);
extern void Desliga_Injetor(void);
extern void Espera_S1(void);
extern void Espera_S2(void);

int main(void){
	MainAsm();
}
