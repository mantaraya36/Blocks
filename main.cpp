#include <QtGui/QApplication>
#include "blocks.h"

int main(int argc, char *argv[])
{
	QApplication a(argc, argv);
	Blocks w;
	w.show();
	
	return a.exec();
}
