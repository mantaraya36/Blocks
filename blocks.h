#ifndef BLOCKS_H
#define BLOCKS_H

#include <QMainWindow>
#include <QHash>
#include <QMutex>

#include "properties.h"
#include "csound.hpp"
#include "csPerfThread.hpp"

namespace Ui {
class Blocks;
}

typedef struct {
	QHash<QString, double> changedValues;
	QMutex mutex;
	Csound *cs;
} CbData;

class Blocks : public QMainWindow
{
	Q_OBJECT
	
public:
	explicit Blocks(QWidget *parent = 0);
	~Blocks();

	void readSettings();
	void writeSettings();
	static void csCallback(void *data);

public Q_SLOTS:
	void intValueChanged(int value);
	void doubleValueChanged(double value);
	
private:
	Ui::Blocks *ui;

	int m_numFiducials;
	QVector<Properties> m_propertiesList;
	Csound *m_cs;
	CsoundPerformanceThread *m_csThread;
	CbData *m_data;

	void connectTabActions(int index);
	void connectChildren(QObject *parent, int index);
};

#endif // BLOCKS_H
