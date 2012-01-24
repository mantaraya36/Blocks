#ifndef FIDUCIALPROPERTIES_H
#define FIDUCIALPROPERTIES_H

#include <QWidget>

namespace Ui {
class FiducialProperties;
}

class FiducialProperties : public QWidget
{
	Q_OBJECT
	
public:
	explicit FiducialProperties(QWidget *parent = 0);
	~FiducialProperties();
	
public Q_SLOTS:
	void modeChangedSlot(int index);
private:
	Ui::FiducialProperties *ui;
signals:
	void modeChanged(int index)
;};

#endif // FIDUCIALPROPERTIES_H
