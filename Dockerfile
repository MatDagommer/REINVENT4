# Use Miniconda3 as the base image
FROM continuumio/miniconda3:latest

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Create a new conda environment
RUN conda create -n reinvent4 python=3.10 -y

# Activate the conda environment
SHELL ["conda", "run", "-n", "reinvent4", "/bin/bash", "-c"]

# Install pip in the conda environment
RUN conda install pip -y

# Install any needed packages specified in requirements-linux-64.lock
RUN pip install --no-cache-dir -r requirements-docker.lock

# Install REINVENT
RUN pip install --no-deps .

# Clone and set up DockStream
RUN git clone https://github.com/MolecularAI/DockStream.git /DockStream && \
    cd /DockStream && \
    conda env create -f environment.yml && \
    conda run -n DockStream /bin/bash -c "\
        cd \$CONDA_PREFIX && \
        mkdir -p ./etc/conda/activate.d && \
        mkdir -p ./etc/conda/deactivate.d && \
        echo '#!/bin/sh' > ./etc/conda/activate.d/env_vars.sh && \
        echo 'export OE_LICENSE=/opt/scp/software/oelicense/1.0/oe_license.seq1' >> ./etc/conda/activate.d/env_vars.sh && \
        echo '#!/bin/sh' > ./etc/conda/deactivate.d/env_vars.sh && \
        echo 'unset OE_LICENSE' >> ./etc/conda/deactivate.d/env_vars.sh"

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME REINVENT4

# Set the default command to run when starting the container
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "reinvent4"]
CMD ["reinvent", "--help"]