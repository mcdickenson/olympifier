# Scraper to collect 2016 US Olympic team data

import csv
import urllib2
import urllib
import re
import time
from BeautifulSoup import BeautifulSoup

sports = [
  'archery',
  'badminton',
  'basketball',
  'boxing',
  'canoe kayak',
  'cycling',
  'diving',
  'equestrian',
  'fencing',
  'field hockey',
  'golf',
  'gymnastics',
  'judo',
  'modern pentathlon',
  'rowing',
  'rugby',
  'sailing',
  'shooting',
  'soccer',
  'swimming',
  'synchronized swimming',
  'table tennis',
  'taekwondo',
  'tennis',
  'track and field',
  'triathlon',
  'volleyball',
  'water polo',
  'weightlifting',
  'wrestling'
]

root_page = 'http://www.teamusa.org/Road-To-Rio-2016/Team-USA/'

header = ['sport', 'name', 'gender', 'height', 'weight', 'dob', 'link', 'img']

def content_from_tag(tag):
  while 'NavigableString' not in str(type(tag)):
    if tag is None or tag.contents == []:
      return ''
    tag = tag.contents[0]
  return tag.replace('&nbsp;', '')

with open('usa2016.csv', 'wb') as f:
  my_writer = csv.writer(f)
  my_writer.writerow(header)

  for sport in sports:
    current_page = root_page + urllib.quote(sport)
    print("\n")
    print("Scraping %s" % current_page)

    # Open the page
    time.sleep(1)
    webpage = urllib2.urlopen(current_page)

    #Parse it
    soup = BeautifulSoup(webpage.read())
    soup.prettify()

    # get all h3s -- this is where gender is recorded
    h3s    = soup.findAll("h3")
    relevant_h3s = [h for h in h3s if ('Men' in str(h)) or ('Women' in str(h))]


    # get all tables
    tables = soup.findAll("table")
    # there are some weird hidden tables with invalid data
    relevant_tables = [t for t in tables if ('Gender' not in str(t))]

    for i in range(len(relevant_tables)):

      # for each table, get the previous h3 ("Men" or "Women")
      if i in range(len(relevant_h3s)):
        h3  = relevant_h3s[i]
        if 'Men' in str(h3):
          gender = 'M'
        elif 'Women' in str(h3):
          gender = 'W'
        else:
          gender = 'NA'
      else:
        gender = 'NA'

      table = relevant_tables[i]
      rows  = table.findAll("tr")

      # within the header of each table, get the index for name, height, weight, and dob
      header_row = rows[0]
      header_tds = header_row.findAll("td")

      name = [x for x in header_tds if 'Name' in str(x)]
      if name == []:
        print('Missing name column')
        continue
      name_ix = header_tds.index(name[0])

      height = [x for x in header_tds if 'Height' in str(x)]
      height_ix = header_tds.index(height[0])

      # the boxing tables contain 'Weight Class'
      weight = [x for x in header_tds if ('Weight' in str(x)) and ('Class' not in str(x))]
      weight_ix = header_tds.index(weight[0])

      dob = [x for x in header_tds if 'DOB' in str(x)]
      dob_ix = header_tds.index(dob[0])

      # find required fields by index
      for data_row in rows[1:]:
        tds = data_row.findAll('td')
        name_td = tds[name_ix]

        # some athletes are missing links
        if name_td.a is None:
          continue

        link = name_td.a['href']

        # some links are corrupt
        if (link == 'http://') or ('/Athletes/UN/' in link):
          continue

        name = content_from_tag(name_td.a)

        height_td = tds[height_ix]
        height = content_from_tag(height_td)

        weight_td = tds[weight_ix]
        weight = content_from_tag(weight_td)

        dob_td = tds[dob_ix]
        dob = content_from_tag(dob_td)

        # visit bio page to get image link
        if 'teamusa.org' not in link:
          link = 'http://www.teamusa.org' + link
        # one of the links has multiple protocols
        link = link.replace('http://http://', 'http://')
        print('Scraping ' + link)
        biopage = urllib2.urlopen(link)

        #Parse it
        biosoup = BeautifulSoup(biopage.read())
        biosoup.prettify()

        div = biosoup.findAll("div", attrs={ "class" : "athlete athlete-hero olympic" })[0]
        imgs = div.findAll('img')
        img = 'http://www.teamusa.org' + imgs[0]['src']

        # write out data
        my_writer.writerow([sport, name, gender, height, weight, dob, link, img])

