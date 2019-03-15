.. VFFVA documentation master file, created by
   sphinx-quickstart on Fri Mar 15 16:59:57 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Summary
================================
VFFVA is a parallel implementation of Flux Variability Analysis (FVA), which delineates the maximal and minimal
bounds for each reaction in a given metabolic model formulated as a Linear Program (LP).
FVA is widely used as it allows to quantify the effect of a perturbation (drug, disease, nutrition) on the system 
as whole and evaluates the response on the reaction actitivity range.
FVA has been originally implemented in MATLAB and Fast FVA (FFVA), the C implementation of FVA, had a great 
speedup on the original implementation through the use of innovative features of the C API of the LP solvers 
IBM CPLEX and GLPK. 
As models grow in size to cover thousands of reactions and metabolites to account for communities of bacteria
and connected systems of organs, FVA is used mostly in parallel. The standard implementation assumes that
each computer cores take an equal chunk of reactions (static load balancing) to process and find 
their minimal and maximal bounds.
In most cases, the chunks of reactions that each core has, are not equal in processing times, despite being
equal in number. The reasons can be manifold as they can related to the core processing speef, the numerical
feasibility of the LP to solve etc. 
VFFVA considers an implementation that assign each worker chunks of reactions that are not equal in size but
are equal in their processing time. This process is achieved through dynamic load balancing, where if a worker
finishes an assigned chunk and stays idle, it is assigned another chunk from an overloaded worker, such that the
load on all workers is equally balanced.

Contents
========

.. toctree::
   :hidden:

   self

.. toctree::

   license/index


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
