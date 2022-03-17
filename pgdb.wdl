version 1.0

workflow pgdb {
	input{
		Boolean add_reference = true
		String? ensembl_downloader_config
		String? ensembl_config
		String gencode_url = "ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19"
		String ensembl_name = "homo_sapiens"
		Boolean? ncrna
		Boolean? pseudogenes
		Boolean? altorfs
		Boolean? ensembl
		Boolean? vcf
		String? vcf_file
		String? af_field
		Boolean? cbioportal
		String cbioportal_accepted_values = "all"
		String cbioportal_filter_column = "CANCER_TYPE"
		String? cbioportal_study_id
		String? cbioportal_config
		Boolean? cosmic
		String? cosmic_celllines
		String? cosmic_user_name
		String? cosmic_password
		String? cosmic_config
		String cosmic_cancer_type = "all"
		String cosmic_cellline_name = "all"
		Boolean? gnomad
		String gnomad_file_url = "gs://gnomad-public/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.vcf.bgz"
		Boolean? decoy
		String decoy_prefix = "Decoy_"
		String decoy_method = "decoypyrat"
		String decoy_enzyme = "Trypsin"
		String? protein_decoy_config
		Boolean? clean_database
		Int minimum_aa = 6
		Boolean? add_stop_codons
		String outdir = "./results"
		String? email
		String final_database_protein = "final_proteinDB.fa"
		Boolean? help
		String publish_dir_mode = "copy"
		Boolean validate_params = true
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String tracedir = "./results/pipeline_info"
		Boolean? show_hidden_params
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			add_reference = add_reference,
			ensembl_downloader_config = ensembl_downloader_config,
			ensembl_config = ensembl_config,
			gencode_url = gencode_url,
			ensembl_name = ensembl_name,
			ncrna = ncrna,
			pseudogenes = pseudogenes,
			altorfs = altorfs,
			ensembl = ensembl,
			vcf = vcf,
			vcf_file = vcf_file,
			af_field = af_field,
			cbioportal = cbioportal,
			cbioportal_accepted_values = cbioportal_accepted_values,
			cbioportal_filter_column = cbioportal_filter_column,
			cbioportal_study_id = cbioportal_study_id,
			cbioportal_config = cbioportal_config,
			cosmic = cosmic,
			cosmic_celllines = cosmic_celllines,
			cosmic_user_name = cosmic_user_name,
			cosmic_password = cosmic_password,
			cosmic_config = cosmic_config,
			cosmic_cancer_type = cosmic_cancer_type,
			cosmic_cellline_name = cosmic_cellline_name,
			gnomad = gnomad,
			gnomad_file_url = gnomad_file_url,
			decoy = decoy,
			decoy_prefix = decoy_prefix,
			decoy_method = decoy_method,
			decoy_enzyme = decoy_enzyme,
			protein_decoy_config = protein_decoy_config,
			clean_database = clean_database,
			minimum_aa = minimum_aa,
			add_stop_codons = add_stop_codons,
			outdir = outdir,
			email = email,
			final_database_protein = final_database_protein,
			help = help,
			publish_dir_mode = publish_dir_mode,
			validate_params = validate_params,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			max_multiqc_email_size = max_multiqc_email_size,
			monochrome_logs = monochrome_logs,
			tracedir = tracedir,
			show_hidden_params = show_hidden_params,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			custom_config_version = custom_config_version,
			custom_config_base = custom_config_base,
			hostnames = hostnames,
			config_profile_name = config_profile_name,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-pgdb/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		Boolean add_reference = true
		String? ensembl_downloader_config
		String? ensembl_config
		String gencode_url = "ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19"
		String ensembl_name = "homo_sapiens"
		Boolean? ncrna
		Boolean? pseudogenes
		Boolean? altorfs
		Boolean? ensembl
		Boolean? vcf
		String? vcf_file
		String? af_field
		Boolean? cbioportal
		String cbioportal_accepted_values = "all"
		String cbioportal_filter_column = "CANCER_TYPE"
		String? cbioportal_study_id
		String? cbioportal_config
		Boolean? cosmic
		String? cosmic_celllines
		String? cosmic_user_name
		String? cosmic_password
		String? cosmic_config
		String cosmic_cancer_type = "all"
		String cosmic_cellline_name = "all"
		Boolean? gnomad
		String gnomad_file_url = "gs://gnomad-public/release/2.1.1/vcf/exomes/gnomad.exomes.r2.1.1.sites.vcf.bgz"
		Boolean? decoy
		String decoy_prefix = "Decoy_"
		String decoy_method = "decoypyrat"
		String decoy_enzyme = "Trypsin"
		String? protein_decoy_config
		Boolean? clean_database
		Int minimum_aa = 6
		Boolean? add_stop_codons
		String outdir = "./results"
		String? email
		String final_database_protein = "final_proteinDB.fa"
		Boolean? help
		String publish_dir_mode = "copy"
		Boolean validate_params = true
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String tracedir = "./results/pipeline_info"
		Boolean? show_hidden_params
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /pgdb-1.0.0  -profile truwl  --input ~{samplesheet} 	~{true="--add_reference  " false="" add_reference}	~{"--ensembl_downloader_config " + ensembl_downloader_config}	~{"--ensembl_config " + ensembl_config}	~{"--gencode_url " + gencode_url}	~{"--ensembl_name " + ensembl_name}	~{true="--ncrna  " false="" ncrna}	~{true="--pseudogenes  " false="" pseudogenes}	~{true="--altorfs  " false="" altorfs}	~{true="--ensembl  " false="" ensembl}	~{true="--vcf  " false="" vcf}	~{"--vcf_file " + vcf_file}	~{"--af_field " + af_field}	~{true="--cbioportal  " false="" cbioportal}	~{"--cbioportal_accepted_values " + cbioportal_accepted_values}	~{"--cbioportal_filter_column " + cbioportal_filter_column}	~{"--cbioportal_study_id " + cbioportal_study_id}	~{"--cbioportal_config " + cbioportal_config}	~{true="--cosmic  " false="" cosmic}	~{"--cosmic_celllines " + cosmic_celllines}	~{"--cosmic_user_name " + cosmic_user_name}	~{"--cosmic_password " + cosmic_password}	~{"--cosmic_config " + cosmic_config}	~{"--cosmic_cancer_type " + cosmic_cancer_type}	~{"--cosmic_cellline_name " + cosmic_cellline_name}	~{true="--gnomad  " false="" gnomad}	~{"--gnomad_file_url " + gnomad_file_url}	~{true="--decoy  " false="" decoy}	~{"--decoy_prefix " + decoy_prefix}	~{"--decoy_method " + decoy_method}	~{"--decoy_enzyme " + decoy_enzyme}	~{"--protein_decoy_config " + protein_decoy_config}	~{true="--clean_database  " false="" clean_database}	~{"--minimum_aa " + minimum_aa}	~{true="--add_stop_codons  " false="" add_stop_codons}	~{"--outdir " + outdir}	~{"--email " + email}	~{"--final_database_protein " + final_database_protein}	~{true="--help  " false="" help}	~{"--publish_dir_mode " + publish_dir_mode}	~{true="--validate_params  " false="" validate_params}	~{"--email_on_fail " + email_on_fail}	~{true="--plaintext_email  " false="" plaintext_email}	~{"--max_multiqc_email_size " + max_multiqc_email_size}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--tracedir " + tracedir}	~{true="--show_hidden_params  " false="" show_hidden_params}	~{"--max_cpus " + max_cpus}	~{"--max_memory " + max_memory}	~{"--max_time " + max_time}	~{"--custom_config_version " + custom_config_version}	~{"--custom_config_base " + custom_config_base}	~{"--hostnames " + hostnames}	~{"--config_profile_name " + config_profile_name}	~{"--config_profile_description " + config_profile_description}	~{"--config_profile_contact " + config_profile_contact}	~{"--config_profile_url " + config_profile_url}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-pgdb:1.0.0_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    