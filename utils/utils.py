import pandas as pd

def df_and_stats(csv_file, param_of_interest, title) -> pd.DataFrame:
    # read datafram in but skip 6 rows of headers
    df = pd.read_csv(csv_file, skiprows=6)

    currency_cols = ["density"]

    # letʻs create a new df_finals with only the row with the largest value for `step` for each run
    # a run is really defined by the combination of all the param_of_interest and the run-number
    # just for my benefit weʻll create an "index" column that is a composite of the params_of_interest and the run-number joined by "_"
    # this is a little nasty.
    comp_cols = [param_of_interest, 'run']
    df_finals = df.loc[df.groupby(comp_cols)['step'].idxmax()]
    df_finals['index'] = df_finals[comp_cols].apply(lambda x: '_'.join(x.astype(str)), axis=1)

    print(f"\n\n======================= {title} =======================\n\n")

    print(f"\n\n=== Statistics grouped by {param_of_interest} ===")
    grouped = df_finals.groupby(param_of_interest)
    # now each currency, and we just use pandas describe()
    for currency in currency_cols:
        print(f"\n-- {currency} --")
        stats = grouped[currency].describe()
        print(stats)

    return df_finals


