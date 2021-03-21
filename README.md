# Introduction to awk
Learn how to get started with [awk (gawk)](https://www.gnu.org/software/gawk/)!

**We recommend going through this walkthrough in [Gitpod](https://gitpod.io/) as Gitpod will have everything we need for this walkthrough. Hit the button below to get started!**
</br>
</br>
[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/adp8ke/example-introduction-to-awk) 
</br>
</br>
If you prefer to do this locally, then you may need to download the latest version of [GNU awk (gawk)](https://www.gnu.org/software/gawk/#download) if you do not have it on your local OS. We also use `sed` in the "real-world" part of the walkthrough, so if you haven't worked with it, check out this repository: [Introduction to sed](https://github.com/Anant/example-introduction-to-sed)

## **1. Basic Printing**

### **1.1 - You can print using a file input or from an input pipe .**

**1.1.1 - Print using input file `lyrics.txt`.**

```bash
awk '{print}' lyrics.txt
```

**1.1.1 - Print using output of pipe.**

```bash
cat lyrics.txt | awk '{print}'
```

## **2. Built-in Variables**

### **2.1 - Print using fields.**
`awk` reads an input record and automatically parses or separates the record into chunks called fields. By default, fields are separated by whitespace, like words in a line. 


**2.1.1 - Print all using `$0`**
```bash
awk '{print $0}' lyrics.txt
```

**2.1.2 - Print the first field using `$1` (or the first word of a sentence, etc)**
```bash
awk '{print $1}' lyrics.txt
```

**2.1.3 - Print multiple fields in any order**
```bash
awk '{print $5, $3}' lyrics.txt
```

### **2.2 - Print using fields and other built-in variables.**

**2.2.1 - Print with numbered lines using `NR`**<br/>
`NR` keeps a current count of the number of input records read so far from all data files. It starts at zero, but is never automatically reset to zero.
```bash
awk '{print NR, $0}' lyrics.txt
```

**2.2.2 - Print ranges of lines using `NR`**<br/>
Only First Line (can be used for getting headers of csv, etc.):
```bash
awk ' NR==1 {print}' lyrics.txt
```

Skip First:
```bash
awk ' NR>1 {print}' lyrics.txt
```

Print Specific Range:
```bash
awk 'NR>4 && NR<9 {print}' lyrics.txt
```

**2.2.3 - Print count of fields using `NF`**<br/>
`NF` contains the number of fields in the current input record. The last field in the input record can be designated by `$NF`, the 2nd-to-last field by `$(NF-1)`, the 3rd-to-last field by `$(NF-2)`, etc

```bash
awk '{print NF, $0}' lyrics.txt
```


**2.2.4 - Print line number and word count using `NR` and `NF`**
```bash
awk '{print "Line", NR, "has a", "word count of", NF}' lyrics.txt
```

## **3. Pattern Matching**

### **3.1 - Match a single pattern and print the first field.** 

```bash
awk '/thunder/ {print $1}' lyrics.txt
```

### **3.2 - Multi-pattern Matching**

**3.2.1 - Print if a either pattern is matched**
```bash
awk '/thunder|magic/ {print $0}' lyrics.txt
```

**3.2.2 - Print if both patterns are matched**
```bash
awk '/Thundercats/ && /loose/ {print $0}' lyrics.txt
```

## **4. Scripts**

### **4.1 - Use UDF to substitute `Thundercats` with `Lightningcats` and print** 

```bash
awk -f script.awk lyrics.txt
```

## **5. Writing Files**

### **5.1 - Using our script in `4.1`, we will write the output to a file instead of the terminal** 

```bash
awk -f script.awk lyrics.txt > substituted.txt
```

### **5.2 - Confirm with `cat`**

```bash
cat substituted.txt 
```

### **5.3 - Do the same thing as `5.1` with `awk` + `sed`** 

```bash
awk '{print NR"." " " $0}' lyrics.txt | sed 's/Thundercats/Lightningcats/' > sed.txt
```

### **5.4 - Confirm with `cat`**

```bash
cat sed.txt 
```

## **6. Real World Application**

### **6.1 - In this “real-world-example”, say we get a CSV file from someone in our company or team and they tell us that it has some issues. They noticed that the first field is missing a value for at least 1 row, and they are unsure of how many other rows are affected. How can we approach this problem with `awk`?**

**6.1.1 - First things first, we could do a quick grep to see how many rows are affected. We can do this by using a `^` to signify the beginning of a line and use it with a comma to be more specific.** 

```bash
grep "^," spacecraft_journey_catalog.csv 
```

**6.1.2 - Great, we can see that at least 10 rows are affected and are missing values for field 1 of the CSV. Now, how can we use this information?**

**6.1.3 - The first thing we can do is create a file with the specific records that are missing values for field one. We will use `-F`, `BEGIN`, and `OFS` in this command to look for rows that have empty fields for field 1,  udpdate field 1 to be "Missing Summary" for those specific rows, and output them back in CSV format.** <br/>
`-F<value>` - Tells `awk` what field separator to use. In our case, we use using `-F,`.<br/>
`BEGIN` - A BEGIN rule is executed once only, before the first input record is read.<br/>
`OFS` - 'O'utput 'F'ield 'S'eparator: stores the "output field separator", which separates the fields when `awk` prints them. The default is a "space" character.

```bash
awk -F, 'BEGIN{OFS=","} /^,/ {$1="Missing Summary";print $0}' spacecraft_journey_catalog.csv > corrupted_rows.csv
```

**6.1.4 - We then run a `cat` to visualize the newly created CSV**

```bash
cat corrupted_rows.csv
```

### **6.2 - Now that we have a file of the “corrupted” data, we could potentially also create a new CSV file that substitutes the rows with `Missing Summary` as a stopgap.** 

**6.2.1 - In the `awk` command, we are running the `stopgap.awk` script, which essentially does the same thing as we did when isolating the records; however, we are still keeping the rest of the records. We then take the entire output and write it into a new CSV called `stopgap.csv`.**

```bash
awk -F, -f stopgap.awk spacecraft_journey_catalog.csv > stopgap.csv
```

**6.2.2 - We then run a `grep` to confirm that the new CSV has used `Missing Summary` as a stopgap for the rows missing values for field one.**
```bash
grep "Missing Summary" stopgap.csv
```

### **6.3 - But wait, that's not all. Say the person who gave us the initial CSV also wants us to do some additional data transformation. The inital `spacecraft_journey_catalog.csv` file has 4 columns: summary, journey_id, end, and start. The person is also asking if we can give them a new CSV with the corrupted rows containing "Missing Summary" for field one, but also they would like us to calculate the duration in days instead of having fields for end time and start time**

**6.3.1 - For this additional request, we will be utitlizing `sed` as well to make it even easier for us. If you are not familiar with `sed`, check out this [repository](https://github.com/Anant/example-introduction-to-sed). We will talk through the steps and then do the whole command in 1 pipe at the end.** 

**6.3.2 - To calculate the time in seconds using the `mktime` function, we will need to do some data cleaning to make our datetime format fit the format required for `mktime`. If we analyze the CSV they gave us, we realize that all the times end in `.000+0000`, which is exactly what we need to clean to utilize `mktime`. We will utilize `sed` to do a global substitution to change (for example) 1981-05-22 13:58:00.000+0000 and 1981-05-14 17:17:00.000+0000 to 1981-05-22 13:58:00 and 1981-05-14 17:17:00**

**6.3.3 - Now that we have done some initial data cleaning using `sed`, we can use awk to do some additional data transformation to change 1981-05-22 13:58:00 to YYYY MM DD HH MM SS, which is the format for `mktime`. We can do this using the `gsub` function and substitute the hyphens and colons with whitespaces for those specific fields/columns**

**6.3.4 - Now that we have our datetimes formatted correctly, we can use `mktime` and calculate the time in seconds. Once calculated, we can subtract the start time from the end time to get a duration in seconds and divide that number by the number of seconds in a day. You can calculate the number of seconds in a day with some quick dimensional analysis (or a quick google search).**

**6.3.5 - Now that we know how to calculate the duration in days, we can print out the summary, journey_id, and duration_in_days per line. However, since there are decimals for the duration_in_days, we can use the `round` function that `gawk` provides to get a nice whole round number**

**6.3.6 - But wait, when we print this out or write it to a new file, the first line/header doesn't match what we need. We can use `sed` again and run another substitution to fix it and then write the desired output to a final CSV file that we can hand back to the person who requested our help**

**6.3.6 - Now, we can run the combined pipe to generate the desired CSV. Again, the first part of the pipe cleans the datetime format, the second part of the pipe is the `duration_calc.awk` script file, which does the `gsub` transformations, `mktime` and `round` calculations, and field printing, and the last part of the pipe fixes the header and writes the final data to a new CSV.**

```bash
sed 's/.000+0000//g' stopgap.csv | awk -F, -f duration_calc.awk | sed 's/summary,journey_id,0/summary,journey_id,duration_in_days/' > duration_by_journey_summary.csv
```

And that will wrap up our walkthrough on basic `awk` operations as well as a potential real-world scenario in which we can use a tool like `awk` in combination with `sed` to do some fast data engineering.

### Additional Resources
- [Live Demo]()
- [Accompanying Blog]()
- [Accompanying SlideShare]()
