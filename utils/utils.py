import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np


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




def plot_from_df_finals(one_d_on_df: pd.DataFrame, one_d_off_df: pd.DataFrame, two_d_on_df: pd.DataFrame, two_d_off_df: pd.DataFrame, one_d_two_d_on_df: pd.DataFrame, one_d_two_d_off_df: pd.DataFrame):

    # need to keep an eye on the y-axis limits for each plot
    y_limits = [0, 0.10]

    fig, axes = plt.subplots(3, 2, figsize=(14, 12), sharex=True)
    fig.suptitle('Mean Mature (step=500) Densities Across Experiments', fontsize=16)

    plt.figtext(0.5, 0.01, 'Shaded regions indicate Standard Error (n = 50 runs)', ha='center', fontsize=12)

    
    param = next(col for col in two_d_on_df.columns if col not in ['run', 'step', 'density', 'index'])

    # very simple plots: we may need to tweak the y axes as the data are very near zero
    
    sns.lineplot(data=two_d_on_df, x=param, y='density', errorbar='se', ax=axes[0, 0])
    axes[0, 0].set_title('2D Life - Wrapping On')
    axes[0, 0].set_ylim(y_limits)
    sns.lineplot(data=two_d_off_df, x=param, y='density', errorbar='se', ax=axes[0, 1])
    axes[0, 1].set_title('2D Life - Wrapping Off')
    axes[0, 1].set_ylim(y_limits)
    sns.lineplot(data=one_d_two_d_on_df, x=param, y='density', errorbar='se', ax=axes[1, 0])
    axes[1, 0].set_title('1D-2D Life - Wrapping On')
    axes[1, 0].set_ylim(y_limits)
    sns.lineplot(data=one_d_two_d_off_df, x=param, y='density', errorbar='se', ax=axes[1, 1])
    axes[1, 1].set_title('1D-2D Life - Wrapping Off')
    axes[1, 1].set_ylim(y_limits)
    sns.lineplot(data=one_d_on_df, x=param, y='density', errorbar='se', ax=axes[2, 0])
    axes[2, 0].set_title('1D Life - Wrapping On')
    axes[2, 0].set_ylim(y_limits)
    sns.lineplot(data=one_d_off_df, x=param, y='density', errorbar='se', ax=axes[2, 1])
    axes[2, 1].set_title('1D Life - Wrapping Off')
    axes[2, 1].set_ylim(y_limits)
    for ax in axes[:, 0]:
        ax.set_ylabel('Mean Density')
    
    for ax in axes[2, :]:
        ax.set_xlabel(param)
    
    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig('density_comparison.png', dpi=300)
    plt.show()
    
    return fig