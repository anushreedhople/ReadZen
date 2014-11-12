enum{
    E_BrightNess=100,
    E_TextSize,
    E_Metrics
};


 typedef enum{
	TextField,
	Label,
	RadioButton,
	CheckBox,
	Button,
	DropDown
}FieldType;

enum{
    EVEN_ROW,
    ODD_ROW,
    SELECTED_ROW
};
enum{
    LEFT,
    RIGHT
};

#define TWO 2
#define ZERO 0
#define ANIMATION_DURATION 0.3
#define PREVIOUS_BTN @"Previous"
#define NEXT_BTN @"Next"
#define DONE_BTN @"Done"
#define LANGUAGE_KEY @"LANGUAGE"
#define DATE_TIME_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define DISPLAY_DATE_FORMAT @"dd/MM/yyyy HH:mm:ss"
#define JOURNEY_DATE_FORMAT @"yyyy-MM-dd"
#define GRIDVIEW_LABEL_TEXTFORMAT @"   %@"
#define US_LOCAL @"en_US_POSIX"
//ALERTS
#define INCORRECT_PWD_FORMAT @"Incorrect Password format"
#define WRONG_PASSWORD @"Wrong Password"
#define TRY_AGAIN @"Try again!!!"
#define DB_OP_FAILED @"Database operation Failed"
#define CURRENT_DATE_TIME_FORMAT @"%04d-%02d-%02d %02d:%02d:%02d"



#define MACRO_CODE_FOR_BG  0xF2EBE4


//For different Colors
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define FONT_TYPE @"Helvetica-Bold"
#define HELEVETICA_NEUE_BOLD @"HelveticaNeue-Bold"
#define HELEVETICA_NEUE @"HelveticaNeue"


