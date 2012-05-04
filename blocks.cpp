#include "blocks.h"
#include "ui_blocks.h"
#include "fiducialproperties.h"

#include <QSettings>
#include <QDebug>
#include <QComboBox>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QInputDialog>
#include <QMessageBox>
#include <QDir>
#include <QProcess>
#include <QTemporaryFile>


Blocks::Blocks(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::Blocks)
{
	ui->setupUi(this);

	QTemporaryFile csdFile(QDir::tempPath () + QDir::separator() + "Blocks-XXXXXX.csd");
	bool op = csdFile.open();
	Q_ASSERT(op);
	QFile internalCsd(":/res/Blocks.csd");
	op = internalCsd.open(QIODevice::ReadOnly);
	Q_ASSERT(op);
	QByteArray data = internalCsd.readAll();
	csdFile.write(data);
	csdFile.flush();
	internalCsd.close();
	m_numFiducials = 12;
	m_data = new CbData;
	for (int i = 0; i < m_numFiducials; i++) {
		int index = ui->tabWidget->addTab(new FiducialProperties(this), QString::number(i));
		connectTabActions(index);
	}
	m_propertiesList.resize(m_numFiducials);
	csoundInitialize(NULL,NULL,NULL);
	m_cs = new Csound();

	QStringList items;
	items << tr("0-") << tr("1-") << tr("2-") << tr("3-") << tr("4-") << tr("5-") << tr("6-");
	bool ok;
	QString text = QInputDialog::getItem(this, tr("Select MIDI interface"),
										 tr("Select MIDI interface number"),
										 items, 0, false, &ok);

	QStringList optionsList;
	optionsList << "csound"<< csdFile.fileName() << "-Q" + text.left(text.indexOf('-'));
	qDebug() << csdFile.fileName();
	char* argv[32];
	for (int i = 0; i < optionsList.size(); i++) {
		argv[i] = (char *) calloc(optionsList.at(i).size() + 1, sizeof(char));
		strcpy(argv[i], optionsList.at(i).toLocal8Bit().constData());
	}
	int result = m_cs->Compile(3,argv);
	m_data->cs = m_cs;
	if (result == 0) {
		m_csThread = new CsoundPerformanceThread(m_cs);
		m_csThread->SetProcessCallback(&Blocks::csCallback, m_data);
		m_csThread->Play(); // Starts performance
	} else {
		QMessageBox::critical(this, tr("Error"), tr("Error running csd. Aborting.\nMake sure Blocks is not already running!"));
		exit(-1);
	}
//	while(m_csThread->GetStatus() == 0) {
//		qApp->processEvents();
//	}
	readSettings();
	for (int i = 0; i < optionsList.size(); i++) {
		free(argv[i]);
	}
#ifdef Q_OS_MACX
	QProcess::execute("open", QStringList() << "/Applications/reacTIVision.app");
#endif
}

Blocks::~Blocks()
{
	m_csThread->Stop();
	m_csThread->Join();
	writeSettings();

#ifdef Q_OS_MACX
	QProcess::startDetached("killall", QStringList() << "/Applications/reacTIVision.app/Contents/MacOS/reacTIVision");
#endif
	delete ui;
}

void Blocks::readSettings()
{
	qDebug() << "readSettings()";
	QSettings s("Cabrera", "Blocks");
}
void Blocks::writeSettings()
{
	qDebug() << "writeSettings()";
	QSettings s("Cabrera", "Blocks");
}

void Blocks::csCallback(void *data)
{
	CbData *d = (CbData *) data;
	d->mutex.lock();
	QHash<QString, double>::const_iterator i;
	QHash<QString, double>::const_iterator end = d->changedValues.constEnd();
	for (i = d->changedValues.constBegin(); i != end; ++i) {
		d->cs->SetChannel(i.key().toLocal8Bit().constData(), (MYFLT)  i.value());
	}
	d->changedValues.clear();
	d->mutex.unlock();
}

void Blocks::intValueChanged(int value)
{
	QString name = "p" + sender()->property("fiducial").toString() + "_"
			+ sender()->property("num").toString();
	m_data->mutex.lock();
	m_data->changedValues.insert(name, (double) value);
	m_data->mutex.unlock();
	qDebug() << "intValueChanged " << sender()->property("fiducial").toString() << sender()->property("num").toString() << value;
}

void Blocks::doubleValueChanged(double value)
{
	QString name = "p" + sender()->property("fiducial").toString() + "_"
			+ sender()->property("num").toString();
	m_data->mutex.lock();
	m_data->changedValues.insert(name, value);
	m_data->mutex.unlock();
	qDebug() << "doubleValueChanged " << sender()->property("fiducial").toString() << sender()->property("num").toString() << value;
}

void Blocks::connectTabActions(int index)
{
	FiducialProperties *fp = static_cast<FiducialProperties *>(ui->tabWidget->widget(index));

	fp->setProperty("num", "0");
	fp->setProperty("fiducial", QString::number(index));
	connect(fp, SIGNAL(modeChanged(int)), this, SLOT(intValueChanged(int)));
	QObjectList children = fp->children();

	foreach(QObject *child, children) {
		connectChildren(child,index);
	}
}

void Blocks::connectChildren(QObject *child, int index)
{
	QVariant prop = child->property("num");
	if (prop.isValid()) {
		const QMetaObject * mo = child->metaObject();
		const char * cname = mo->className();
		if (child->property("num").toInt() == 5
		        || child->property("num").toInt() == 19
		        || child->property("num").toInt() == 26
		        || child->property("num").toInt() == 45
		        || child->property("num").toInt() == 7
		        || child->property("num").toInt() == 11
		        || child->property("num").toInt() == 15) { // Channel
			static_cast<QSpinBox *>(child)->setValue(index + 1);
		}
		if (!strncmp(cname,"QComboBox", strlen(cname))) {
			connect(static_cast<QComboBox *>(child), SIGNAL(currentIndexChanged(int)),
					this, SLOT(intValueChanged(int)));
			child->setProperty("fiducial", QString::number(index));
			QString propName = "p" + QString::number(index) + "_"
					+ child->property("num").toString();
			m_data->changedValues.insert(propName, (double) static_cast<QComboBox *>(child)->currentIndex());
		} else if (!strncmp(cname,"QSpinBox", strlen(cname))) {
			connect(static_cast<QSpinBox *>(child), SIGNAL(valueChanged(int)),
					this, SLOT(intValueChanged(int)));
			child->setProperty("fiducial", QString::number(index));
			QString propName = "p" + QString::number(index) + "_"
					+ child->property("num").toString();
			m_data->changedValues.insert(propName, (double) static_cast<QSpinBox *>(child)->value());
		} if (!strncmp(cname,"QDoubleSpinBox", strlen(cname))) {
			connect(static_cast<QDoubleSpinBox *>(child), SIGNAL(valueChanged(double)),
					this, SLOT(doubleValueChanged(double)));
			child->setProperty("fiducial", QString::number(index));
			QString propName = "p" + QString::number(index) + "_"
					+ child->property("num").toString();
			m_data->changedValues.insert(propName, (double) static_cast<QDoubleSpinBox *>(child)->value());
		}
	}
	QObjectList children = child->children();
	foreach(QObject *newchild, children) {
		connectChildren(newchild, index);
	}
}

