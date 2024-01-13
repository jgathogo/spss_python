import pyreadstat

# Path to your SPSS file
spss_file_path = 'data/adult19.sav'

# Reading the SPSS file
df, meta = pyreadstat.read_sav(spss_file_path)

# Save variable labels and value labels to a Python file
with open('metadata.py', 'w') as file:
    file.write(f"variable_labels = {meta.column_labels}\n")
    file.write(f"value_labels = {meta.variable_value_labels}\n")
