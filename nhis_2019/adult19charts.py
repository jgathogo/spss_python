import streamlit as st
import plotly.express as px
import pandas as pd

from metadata import variable_labels, value_labels

# Load your DataFrame from a CSV file
csv_file_path = 'adult19.csv'
df = pd.read_csv(csv_file_path)

cols = ['VISIONDF_A', 'HEARINGDF_A', 'DIFF_A', 'COGMEMDFF_A', 'UPPSLFCR_A', 'COMDIFF_A']

# Define the conditions for SUM_234, where levels 2, 3, or 4 indicate some difficulty
sum_234_conditions = [(df[col] >= 2) & (df[col] <= 4) for col in cols]
df['SUM_234'] = sum(sum_234_conditions)

# For records missing all domain values, set SUM_234 to missing
df.loc[df[cols].isna().all(axis=1), 'SUM_234'] = pd.NA

# Define the conditions for SUM_34, where levels 3 or 4 indicate a lot of difficulty or cannot do at all
sum_34_conditions = [(df[col] >= 3) & (df[col] <= 4) for col in cols]
df['SUM_34'] = sum(sum_34_conditions)

# For records missing all domain values, set SUM_34 to missing
df.loc[df[cols].isna().all(axis=1), 'SUM_34'] = pd.NA

# Replace value codes with value labels for each variable
for column in df.columns:
    if column in value_labels:
        df[column] = df[column].map(value_labels[column])

# Treat 'Refused', 'Not Ascertained', "Don't Know" as missing values
missing_values = ['7 Refused', '8 Not Ascertained', "9 Don't Know"]
for col in cols:
    df[col] = df[col].replace(missing_values, pd.NA)

# Create a new DataFrame for the disability variables
disability_df = pd.DataFrame()

# Define the conditions for DISABILITY1 to DISABILITY4 and add them to the disability DataFrame
disability_df['DISABILITY1'] = (df['SUM_234'] >= 1).astype(int)
disability_df['DISABILITY2'] = ((df['SUM_234'] >= 2) | (df['SUM_34'] >= 1)).astype(int)
disability_df['DISABILITY3'] = df[cols].isin([3, 4]).any(axis=1).astype(int)
disability_df['DISABILITY4'] = df[cols].isin([4]).any(axis=1).astype(int)

# Set missing values for Disability Identifiers in the disability DataFrame
for col in ['DISABILITY1', 'DISABILITY2', 'DISABILITY3', 'DISABILITY4']:
    disability_df.loc[df[cols].isna().all(axis=1), col] = pd.NA

# Map the numeric values to 'with disability' or 'without disability'
disability_mapping = {0: 'without disability', 1: 'with disability'}
for col in ['DISABILITY1', 'DISABILITY2', 'DISABILITY3', 'DISABILITY4']:
    disability_df[col] = disability_df[col].map(disability_mapping)

# Concatenate the disability DataFrame with the original df
df = pd.concat([df, disability_df], axis=1)

# Heading and Description
st.title('Domain Variables and Disability Identifier Frequencies')
st.write('This page presents a static analysis showing the frequencies of domain variables and disability identifiers. The results displayed are based on the Washington Group’s Analytic Guidelines: Creating Disability Identifiers Using the Washington Group Short Set on Functioning — Enhanced (WG-SS Enhanced) SPSS Syntax.')
st.markdown('[View the Guidelines](https://www.washingtongroup-disability.com/fileadmin/uploads/wg/WG_Document__7A_-_Analytic_Guidelines_for_the_WG-SS_Enhanced__SPSS_.pdf)', unsafe_allow_html=True)

# Function to create and display a bar chart
def create_and_display_chart(column_name, title, x_label, y_label):
    freq = df[column_name].value_counts(dropna=True)
    fig = px.bar(freq, x=freq.index, y=freq.values,
                 labels={'x': x_label, 'y': y_label},
                 title=title)
    st.plotly_chart(fig)

# Generate and display charts for each domain variable
st.subheader('Frequency Distributions for Domain Variables')
for col in cols:
    create_and_display_chart(col, variable_labels[df.columns.get_loc(col)], 'Category', 'Frequency')

# Generate and display charts for each Disability Identifier
st.subheader('Frequencies of Disability Identifiers')
for col in ['DISABILITY1', 'DISABILITY2', 'DISABILITY3', 'DISABILITY4']:
    create_and_display_chart(col, f'Frequency of {col}', 'Category', 'Count')