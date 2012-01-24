#ifndef PROPERTIES_H
#define PROPERTIES_H

#include <QVector>
#include <QVariant>

class Properties
{
public:
	Properties(int number = 50);

	void setProperty(int num, QVariant value);
	QVariant getProperty(int num);

	QVector<QVariant> m_properties;
};

#endif // PROPERTIES_H
