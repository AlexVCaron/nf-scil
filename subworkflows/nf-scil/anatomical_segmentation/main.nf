// ** Importing modules from nf-scil ** //
include { SEGMENTATION_FASTSEG       } from '../../../modules/nf-scil/segmentation/fastseg/main'
include { SEGMENTATION_FREESURFERSEG } from '../../../modules/nf-scil/segmentation/freesurferseg/main'

workflow ANATOMICAL_SEGMENTATION {

    // ** Two input channels for the segmentation processes since they are using ** //
    // ** different image files.                                                 ** //
    take:
        ch_image            // channel: [ val(meta), [ image ] ]
        ch_freesurferseg    // channel: [ val(meta), [ aparc_aseg, wmparc ] ], optional

    main:

        ch_versions = Channel.empty()

        if ( ch_freesurferseg ) {
            // ** Freesurfer segmentation ** //
            SEGMENTATION_FREESURFERSEG ( ch_freesurferseg )
            ch_versions = ch_versions.mix(SEGMENTATION_FREESURFERSEG.out.versions.first())

            // ** Setting outputs ** //
            wm_mask = SEGMENTATION_FREESURFERSEG.out.wm_mask
            gm_mask = SEGMENTATION_FREESURFERSEG.out.gm_mask
            csf_mask = SEGMENTATION_FREESURFERSEG.out.csf_mask
        }
        else {
            // ** FSL fast segmentation ** //
            SEGMENTATION_FASTSEG ( ch_image )
            ch_versions = ch_versions.mix(SEGMENTATION_FASTSEG.out.versions.first())

            // ** Setting outputs ** //
            wm_mask = SEGMENTATION_FASTSEG.out.wm_mask
            gm_mask = SEGMENTATION_FASTSEG.out.gm_mask
            csf_mask = SEGMENTATION_FASTSEG.out.csf_mask
            wm_map = SEGMENTATION_FASTSEG.out.wm_map
            gm_map = SEGMENTATION_FASTSEG.out.gm_map
            csf_map = SEGMENTATION_FASTSEG.out.csf_map
        }

    emit:
    // TODO nf-core: edit emitted channels
    wm_mask   = wm_mask                     // channel: [ val(meta), [ wm_mask ] ]
    gm_mask   = gm_mask                     // channel: [ val(meta), [ gm_mask ] ]
    csf_mask  = csf_mask                    // channel: [ val(meta), [ csf_mask ] ]
    wm_map    = wm_map, optional: true      // channel: [ val(meta), [ wm_map ] ]
    gm_map    = gm_map, optional: true      // channel: [ val(meta), [ gm_map ] ]
    csf_map   = csf_map, optional: true     // channel: [ val(meta), [ csf_map ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

