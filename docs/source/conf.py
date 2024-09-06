# Configuration file for the Sphinx documentation builder.

# -- Project information
import os
import subprocess
import logging
from sphinx.application import Sphinx


# Dashboard Generation
import os
import subprocess
import logging
from sphinx.application import Sphinx


project = "MEG Pipeline"
copyright = "2024, Hadi Zaatiti"
author = "Hadi Zaatiti hadi.zaatiti@nyu.edu"

release = "0.1"
version = "0.1.0"

# -- General configuration

extensions = [
    "sphinx.ext.duration",
    "sphinx.ext.doctest",
    "sphinx.ext.autodoc",
    "sphinx.ext.autosummary",
    "sphinx.ext.intersphinx",
    "nbsphinx",
    "sphinx_gallery.load_style",
    "sphinx.ext.mathjax",
]

intersphinx_mapping = {
    "python": ("https://docs.python.org/3/", None),
    "sphinx": ("https://www.sphinx-doc.org/en/master/", None),
}
intersphinx_disabled_domains = ["std"]

templates_path = ["_templates"]

# -- Options for HTML output

html_theme = "sphinx_rtd_theme"
html_logo = "graphic/NYU_Logo.png"
html_theme_options = {
    "logo_only": False,
    "display_version": True,
    "prev_next_buttons_location": "bottom",
    "style_external_links": False,
    "vcs_pageview_mode": "",
    "style_nav_header_background": "#561A70",
    # Toc options
    "collapse_navigation": True,
    "sticky_navigation": True,
    "navigation_depth": 4,
    "includehidden": True,
    "titles_only": False,
}

suppress_warnings = [
    "epub.unknown_project_files"
]  # This allows us to avoid the warning caused by html files in _static directory (regarding mime types)

html_css_files = [
    "custom.css",
]

html_static_path = ["_static"]
# -- Options for EPUB output
epub_show_urls = "footnote"


def run_dashboard_generation(app: Sphinx):
    """Run the dashboard generation script."""
    logger = logging.getLogger(__name__)
    script_path = os.path.join(app.confdir, "dashboards", "generate_snr_dashboard.py")
    if os.path.exists(script_path):
        logger.info(
            f"Found generate_snr_dashboard.py at {script_path}, running it now."
        )
        result = subprocess.run(["python", script_path], capture_output=True, text=True)
        if result.returncode == 0:
            logger.info("generate_snr_dashboard.py ran successfully.")
        else:
            logger.error(
                f"generate_snr_dashboard.py failed with return code {result.returncode}"
            )
            logger.error(result.stdout)
            logger.error(result.stderr)
    else:
        logger.error(f"The script {script_path} does not exist.")


def run_csv_conversion(app):
    logger = logging.getLogger(__name__)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    script_path = os.path.abspath(
        os.path.join(current_dir, "scripts", "convert_csv_to_rst.py")
    )

    if os.path.exists(script_path):
        logger.info(
            f"Found convert_csv_to_rst.py at {script_path}, running it now."
        )

        result = subprocess.run(["python", script_path], check=True)

        if result.returncode == 0:
            logger.info("convert_csv_to_rst.py ran successfully.")
        else:
            logger.error(
                f"convert_csv_to_rst.py failed with return code {result.returncode}"
            )
            logger.error(result.stdout)
            logger.error(result.stderr)
            raise RuntimeError(
                f"CSV to RST conversion script failed with exit code {result.returncode}"
            )
    else:
        logger.error(f"The script {script_path} does not exist.")


def setup(app: Sphinx):
    logging.basicConfig(level=logging.INFO)
    app.connect("builder-inited", run_dashboard_generation)
    app.connect("builder-inited", run_csv_conversion)
