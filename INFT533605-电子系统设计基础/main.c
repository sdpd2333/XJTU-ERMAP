//包含头文件
#include <reg51.h>//51单片机头文件
#include <absacc.h>//51单片机寄存器头文件


//定义变量
//定义了一个8位的数据存储器，用于存储按键的值
unsigned char code SEG[8] = 
{0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01};

//定义了一个16个元素的数组，用于存储16个字符的段码
unsigned char code duan[16] =
{0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,
0x7f,0x6f,0x77,0x7c,0x39,0x5e,0x79,0x71};

//定义了一个16个元素的数组，用于存储16个字符的键码
unsigned char code change[16] = 
{0x11,0x21,0x41,0x81,0x12,0x22,0x42,0x82,
0x14,0x24,0x44,0x84,0x18,0x28,0x48,0x88
};

//定义了一个8位的数据存储器，用于存储（学号）
int stu[8] = {2,4,4,1,1,5,4,6};


//定义函数
//延时函数，参数：count，延时的时间，返回值：无，功能：延时一段时间
void delay(int count)
{
	int i;
	for(i=1;i<=count;i++);
}

//显示函数，参数：duan_num，段码的编号，wei_num，位码的编号，返回值：无，功能：显示段码和位码
void show(unsigned char duan_num, unsigned char wei_num)
{
	//定义变量
	XBYTE[0x8000] = wei_num;

	//显示段码
	XBYTE[0x9000] = duan[duan_num];

	//延时一段时间
	delay(20);

	//清零
	XBYTE[0x9000] = 0x00;
}

//获取按键函数，参数：无，返回值：按键的键码，功能：获取按键的键码
int	getkeycode(void)
{
	//定义变量
	unsigned char col = 0x00;
	unsigned char line = 0x00;
	unsigned char scancode = 0x01;
	unsigned char keycode;
	int	i;
	
	//获取按键的键码
	XBYTE[0x8000] = 0xff;

	//获取按键的列码
	col = XBYTE[0x8000]&0x0f;

	if(col == 0x00) return 16;
	else
	{
		while((scancode&0x0f) != 0)
		{
			line = scancode;
			XBYTE[0x8000] = scancode;
			if((XBYTE[0x8000]&0x0f) == col)
				break;
			scancode = scancode << 1;
		}
		col = col << 4;
		keycode = col|line;
	}
	for(i=0;i<16;i++)
	{
		if(keycode == change[i])
		{
			return i;
		}
	}
}
/*
//主函数，流水灯
void	main(void)
{
	//定义变量
	int		j;
	int		i;
	unsigned char	num;
	//显示函数
	while(1)
	{
			for(j=0;j<8;j++)
			{
				num = getkeycode();
				if(num != 16)
					for(i=0;i<1200;i++)
						show(num, SEG[j]);
			}
	}
}
*/
/*
//主函数，全部显示
void	main(void)
{
	//定义变量
	int		i;
	int		j;
	int		k = 0;
	unsigned char	num;
	//显示函数
	while(1)
	{
		for(i=0;i<250;i++)
		{
			num = getkeycode();
			for(j=0;j<1200;j++)
				show(num, SEG[j]);
		}
	}
}
*/

//主函数，流水灯显示学号
void	main(void)
{
	//定义变量
	int		i;
	int		j;
	int		k = 0;
	//显示函数
	while(1)
	{
		for(i=0;i<250;i++)
		{
			for(j=0;j<8;j++)
				show(stu[j], SEG[(j+k)%10]);
		}
		k++;
	}
}