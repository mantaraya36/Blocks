#include "properties.h"

Properties::Properties(int number)
{
	m_properties.resize(number);
}

void Properties::setProperty(int num, QVariant value)
{
	m_properties[num] = value;
}

QVariant Properties::getProperty(int num)
{
	return m_properties[num];
}
