#include "fiducialproperties.h"
#include "ui_fiducialproperties.h"

FiducialProperties::FiducialProperties(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::FiducialProperties)
{
	ui->setupUi(this);
	ui->modeTabWidget->setCurrentIndex(0);
	connect(ui->modeTabWidget,SIGNAL(currentChanged(int)),this, SLOT(modeChangedSlot(int)));
}

FiducialProperties::~FiducialProperties()
{
	delete ui;
}

void FiducialProperties::modeChangedSlot(int index)
{
	emit modeChanged(index);
}
