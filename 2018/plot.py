import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns


# load data - downloaded from https://www.teamusa.org/-/media/TeamUSA/PyeongChang2018/TeamAnnouncement/2018-US-Olympic-Team-Roster.xlsx?la=en&hash=663E5D117172DACB47858A40BE7F95C9992D7D84
athletes = pd.read_csv('2018USOlympicTeamRoster.csv')

# helper functions
def height_to_inches(height_string):
    if type(height_string) != str:
        return np.nan
    feet, inches = height_string.strip('"').split("'")
    return int(feet) * 12 + int(inches)


# clean up columns
athletes['name'] = athletes['First Name'] + ' ' + athletes['Last Name']
athletes['sport'] = athletes['Event(s)/ Position ']
athletes['height'] = athletes['Height'].apply(lambda x: height_to_inches(x))
athletes['weight'] = athletes['Weight']
athletes['age'] = athletes['Age (As of 2/8/18)']
athletes['female'] = athletes['Gender'] == 'F'

# subset columns
subset = athletes.ix[:, 'name':'female']
complete = np.all(subset.notnull(), axis=1)
subset = subset[complete]
subset.to_csv('athletes.csv', index=False)

sns.jointplot("height", "weight", subset, kind='reg')
# plt.show()