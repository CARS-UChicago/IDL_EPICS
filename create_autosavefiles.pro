;+
; NAME:
;       CREATE_AUTOSAVEFILES
;
; PURPOSE:
;       This procedure builds request files for the EPICS save/restore
;       software which periodically saves process variables and then restores
;       them on reboot. These files are typically called auto_positions.req and
;       auto_settings.req. It also creates scanParms.template, for scan
;       parameters.
;       This procedure is intended to be used as follows:
;           - This procedure itself is intended to be modified in a
;             "site-specific" manner.  Each site manager decides which fields
;             in a given record type are put in the save/restore files, and
;             which are loaded from .db or .templates files each time the IOC
;             boots.  The distribution file contains the choices made for
;             GSECARS, sector 13 at the APS.  For example, some intallations
;             may want to save and restore nearly all of the settings for the
;             motor record.  At GSECARS we decided that most motor parameters
;             would be defined in the a motors.template files in the
;             iocBoot/iocxxx directory so that we can get back to a "known
;             state" for each motor on a reboot.  Thus, this file only puts the
;             .OFF and .DVAL fields in the auto_positions.req file and the
;             .DHLM, .DLLM, .TWV, .DISA, .DISP fields in the auto_settings.req
;             file.
;
;           - Each iocBoot/iocxxx directory contains a file typically called
;             make_savefiles.pro which invokes this procedure to create the
;             request files specific to that IOC.
;
; CATEGORY:
;       IDL EPICS support.
;
; CALLING SEQUENCE:
;       CREATE_AUTOSAVEFILES
;
; INPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       There are many keyword parameters, once for each type of EPICS record
;       which is supported by this software.  There are two types of keywords.
;       The first type is used to specify a list of records, and is passed as
;       a string array.  For example MCAS=['aim_adc1', 'aim_adc2'].  This is
;       used for record types for which there are typically only a few records,
;       and for which no standard naming convention exists. The second type of
;       keyword parameter is used to specify the number of records for record
;       type for which a standard naming convention exists, for example
;       NMOTORS=48.  This saves the trouble of passing a 48 element string
;       array to list the name of each motor, though that is still possible
;       e.g. MOTORS=['m1', 'm2', 'm3, ...].
;
;       PREFIX:
;           A string prefix which is placed before all PV names, e.g. '13BMD:'
;       NMOTORS:
;           The number of motors.  The naming convention assumed for motors
;           is PREFIX+'m1', PREFIX+'m2', etc.
;       MOTORS:
;           A string array of motor names.  This keyword is incompatible with
;           the NMOTORS keyword.
;       NPSEUDOMOTORS:
;           The number of motor with "soft record" device support. The naming
;           convention assumed for pseudomotors is PREFIX+'pm1', etc.
;       PSEUDOMOTORS:
;           A string array of pseudomotor names.  This keyword is incompatible
;           with the NPSEUDOMOTORS keyword.
;       TABLES:
;           A string array containing the names of table records.
;       NSCANS:
;           The number of scan records.  The naming convention assumed for
;           scan records is PREFIX+'scan1', PREFIX+'scan2', etc.
;       SCANS:
;           A string array of scan record names.  This keyword is incompatible
;           with the SCANS keyword.
;       CURRENT_PREAMPS:
;           A string array containing the names of current preamps (SRS 570s)
;       DACS:
;           A string array containing the names of DACs (Systran DAC 128V)
;       DMMS:
;           A string array containing the names of Keithley 2000 Digital
;           Multimeters.;
;       ICB_DSPS:
;           A string array containing the names of Canberra ICB DSP 9660 modules
;       ICB_AMPS:
;           A string array containing the names of Canberra ICB Amplifiers
;       ICB_ADCS:
;           A string array containing the names of Canberra ICB ADCs
;       ICB_HVPS:
;           A string array containing the names of Canberra ICB HVPS
;       ICB_TCAS:
;           A string array containing the names of Canberra ICB TCAS
;       FEEDBACK:
;           A string array containing the names of EPID feedback records
;       MCAS:
;           A string array containing the names of MCA records
;       MPCS:
;           A string array containing the names of MPC ion pump controllers
;       MPC_TSPS:
;           A string array containing the names of MPC TSP pumps
;       PIEZOS:
;           A string array containing the names of Piezos
;       SIMPLE_MCAS:
;           A string array containing the names of MCA records loaded with the
;           simple_mca.db database which has fewer fields, and is used for
;           multi-element detector databases.
;       SMART:
;           A string array containing the names of SMART database records loaded with
;           the smartControl.db database.
;       SETTINGS_FILE:
;           A string array containing the names of the output settings file.
;           The default name is "auto_settings.req".
;       POSITIONS_FILE:
;           A string array containing the names of the output positions file.
;           The default name is "auto_positions.req".
;       SCANPARMS_FILE:
;           A string array containing the names of the output scan parameters
;           file. The default name is "scanParms.template".
;
; OUTPUTS:
;       This procedure creates 3 disk files.  By default their names are
;       "auto_positions.req", "auto_settings.req" and "scanParms.template".
;       These names can be changed with the keyword parameters.
;
; RESTRICTIONS:
;       - This procedure makes specific choices about what fields to save and
;         restore.
;       - This procedure makes assumptions about what databases are used to
;         load records, since in many cases it is not just fields within a
;         specific record type which are saved, but fields from other
;         associated records from the database.
;       - It makes assumptions about how records are named, for example motor
;         records are assumed to be named 'prefix'm1, 'prefix'm2, etc.
;       - It only knows about a small subset of EPICS records.
;
;       It should be modified to suit the requirements of a specific EPICS
;       site.
;
; EXAMPLE:
;       The following is a file called "make_savefiles.pro" from an
;       iocBoot/iocxxx directory.  This file is a main program which is run
;       by typing "IDL> .run make_savefiles".
;
;       prefix          = '13IDD:'
;       tables          = ['DAC:t1']
;       scalers         = ['scaler1']
;       current_preamps = ['A1', 'A2','A3']
;       icb_amps        = ['amp1']
;       icb_adcs        = ['adc1']
;       icb_hvps        = ['hvps1']
;       mcas            = ['aim_adc1', 'aim_mcs1', 'mip330_1', 'mip330_2']
;       dmms            = ['DMM1','DMM3','DMM4']
;       feedback        = ['PID1','PID2']
;
;       create_autosavefiles, prefix          = prefix,          $
;                      nmotors         = 64,              $
;                      npseudomotors   = 11,              $
;                      nscans          = 4,               $
;                      tables          = tables,          $
;                      scalers         = scalers,         $
;                      current_preamps = current_preamps, $
;                      icb_amps        = icb_amps,        $
;                      icb_adcs        = icb_adcs,        $
;                      icb_hvps        = icb_hvps,        $
;                      dmms            = dmms,            $
;                      energy          = energy,          $
;                      mcas            = mcas,            $
;                      feedback        = feedback
;       end
;
; MODIFICATION HISTORY:
;       Written by:     Mark Rivers, original date 1996?
;
;       23-APR-1999     MLR Added new PVs and fields for MCA record and ADC
;                           subroutine record
;       22-SEP-1999     MLR Added new_scan keyword for synApps scanning
;                           without wait records
;       03-DEC-1999     MLR Modified records for MCA database for mca_2.0.db
;       23-JAN-2000     MLR Added support scanParams.template, modified
;                           pseudomotor support
;       18-FEB-2000     MLR Added init_string to DMM settings.
;       22-FEB-2000     MLR Added feedback records
;       09-APR-2000     MLR Added simple_mcas for use with multielement
;                           detectors
;       13-MAY-2000     MLR Added documentation header, removed NEW_SCAN
;                           keyword, old scans are no longer supported;
;       01-JUN-2000     MN  Added saving of Energy database values
;       20-JUN-2000     MLR Added DACs to scanParams.template
;       13-SEP-2000     MLR Added dsps for Canberra 9600 DSP modules
;       18-SEP-2000     MLR Added SMART for Bruker SMART detector databases
;       05-OCT-2000     MLR Changed ICB ADC to use new database
;       11-OCT-2000     MLR Changed ICB AMP to use new database
;       12-OCT-2000     MLR Changed ICB HVPS to use new database
;       15-OCT-2000     MLR Added ICB TCAS for Canberra TCA modules
;       16-OCT-2000     MLR Added autocount fields for scaler record
;       25-OCT-2000     MLR Increased scaler channels from 16 to 32.
;       23-JAN-2001     MN  Added piezo settings (from singleDAC.db --
;                           'dac' keyword already in use)
;       30-JAN-2001     MLR Delete dummy scan PVs which were used in scan_4.9.db
;                           but don't exist in scan_5.0.db
;       19-FEB-2001     MLR Add support for MPC ion pump controller with TSP
;       05-MAR-2001     MLR Break MPC support into MPC and MPC_TSP
;       15-MAR-2001     MLR Add "FOFF" field to motor_settings
;       19-MAY-2001     MLR Add "FMOD" field to feedback_settings
;       06-JUN-2001     MLR Added DXPS for XIA DXP-4C modules
;       21-AUG-2001     MLR Added tweak values for DACS and offset for pseudomotors
;       24-AUG-2001     MLR Increased number of ROIs in MCA records from 10 to 32.
;       1-OCT-2001      MLR Changed scanParams.template to use new syntax
;       13-JAN-2002     MLR Changed dxp_settings for new record fields
;       12-MAR-2002     MLR Changed dxp_settings for new record fields
;       28-AUG-2002     MN  Added user transform record (for 13IDA feedback calcs)
;       12-SEP-2002     MLR Added Fluke_8842A
;       12-SEP-2002     MLR Added PGAIN field for DXPs
;       12-MAR-2003     MLR Added support for Heidenhein IK320 and hrm (high-resolution monochromator)
;       26-MAR-2003     MLR Fixed bug with user_transform records, didn't work with more than 1.
;-

pro create_autosavefiles,   prefix          = prefix,          $
                            nmotors         = nmotors,         $
                            motors          = motors,          $
                            npseudomotors   = npseudomotors,   $
                            pseudomotors    = pseudomotors,    $
                            tables          = tables,          $
                            scalers         = scalers,         $
                            nscans          = nscans,          $
                            current_preamps = current_preamps, $
                            dacs            = dacs,            $
                            dmms            = dmms,            $
                            icb_amps        = icb_amps,        $
                            icb_adcs        = icb_adcs,        $
                            icb_dsps        = icb_dsps,        $
                            icb_hvps        = icb_hvps,        $
                            icb_tcas        = icb_tcas,        $
                            settings_file   = settings_file,   $
                            positions_file  = positions_file,  $
                            scanparms_file  = scanparms_file,  $
                            feedback        = feedback,        $
                            mcas            = mcas,            $
                            user_transform  = user_transform,  $
                            energy          = energy,          $
                            piezos          = piezos,          $
                            smart           = smart,           $
                            mpcs            = mpcs,            $
                            mpc_tsps        = mpc_tsps,        $
                            dxps            = dxps,            $
                            newport_snl     = newport_snl,     $
                            fluke_8842As    = fluke_8842As,    $
                            ik320s          = ik320s,          $
                            hrms            = hrms,            $
                            simple_mcas     = simple_mcas

if n_elements(settings_file) eq 0 then settings_file = 'auto_settings.req'
if n_elements(positions_file) eq 0 then positions_file = 'auto_positions.req'
if n_elements(scanparms_file) eq 0 then scanparms_file = 'scanParms.template'

if (n_elements(prefix) eq 0) then prefix = ''


; Make trimmed strings of digits
numbers = strtrim(sindgen(100), 2)
letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L']

; Build motor names
if (n_elements(motors) eq 0) then begin
    if (n_elements(nmotors) ne 0) then begin
        if (nmotors gt 0) then begin
            motors = strarr(nmotors)
            for i=1, nmotors do begin
                motors(i-1) = 'm' + numbers(i)
            endfor
        endif
    endif
endif

; Build pseudomotor names
if (n_elements(pseudomotors) eq 0) then begin
    if (n_elements(npseudomotors) ne 0) then begin
        if (npseudomotors gt 0) then begin
            pseudomotors = strarr(npseudomotors)
            for i=1, npseudomotors do begin
                pseudomotors(i-1) = 'pm' + numbers(i)
            endfor
        endif
    endif
endif

if n_elements(nscans) gt 0 then begin
    scans = strarr(nscans)
    for i=1, nscans do begin
        scans(i-1) = 'scan'  + numbers(i)
    endfor
endif

; First define which fields in each record get saved.
motor_positions = ['.OFF', $
                   '.DVAL']
motor_settings  = ['.DHLM', $
                   '.DLLM', $
                   '.FOFF', $
                   '.TWV',  $
                   '.DISA', $
                   '.DISP', $
                   ':scanParms.SP', $
                   ':scanParms.EP', $
                   ':scanParms.NP', $
                   '_able.VAL']
table_settings  = ['.YANG', $
                   '.SX',   $
                   '.LX',   $
                   '.SZ',   $
                   '.LZ',   $
                   '.SY',   $
                   '.RX',   $
                   '.RY',   $
                   '.RZ',   $
                   '.LEGU', $
                   '.AEGU', $
                   '.PREC', $
                   '.SSET', $
                   '.SUSE', $
                   '.UHX',    $
                   '.UHY',    $
                   '.UHZ',    $
                   '.UHAX',   $
                   '.UHAY',   $
                   '.UHAZ',   $
                   '.ULX',    $
                   '.ULY',    $
                   '.ULZ',    $
                   '.ULAX',   $
                   '.ULAY',   $
                   '.ULAZ',   $
                   '.GEOM',   $
                   '.DESC']

scan_settings   = ['.NPTS', $
                   '.PASM', $
                   '.SCAN', $
                   '.BSPV', $
                   '.ASPV', $
                   '.T1PV', $
                   '.T2PV']
;{ Matt 14-nov-98  saving all 15 detectors  (0-9,A-F)
for i=1, 9  do scan_settings = [scan_settings, '.D' + numbers(i) + 'PV']
for i=0, 5  do scan_settings = [scan_settings, '.D' + letters(i) + 'PV']
;  Matt 25-sep-00  saving all 70 detectors  (01 .. 07)
for i=1,70  do begin
  s = '.D' + string(format='(i2.2)', i) + 'PV'
  scan_settings = [scan_settings, s]
endfor
;}
for i=1, 4 do scan_settings = [scan_settings, '.P' + numbers(i) + 'PV']
for i=1, 4 do scan_settings = [scan_settings, '.R' + numbers(i) + 'PV']
for i=1, 4 do scan_settings = [scan_settings, '.P' + numbers(i) + 'SM']
for i=1, 4 do scan_settings = [scan_settings, '.P' + numbers(i) + 'SP']
for i=1, 4 do scan_settings = [scan_settings, '.P' + numbers(i) + 'EP']
for i=1, 4 do scan_settings = [scan_settings, '.P' + numbers(i) + 'AR']

wait_settings = ['.CALC', $
                 '.OUTN', $
                 '.OOPT', $
                 '.DOPT', $
                 '.DOLN', $
                 '.SCAN', $
                 '.ODLY', $
                 '.PREC', $
                 '.OEVT']
for i=0, 11 do wait_settings = [wait_settings, '.IN' + letters(i) + 'N']
for i=0, 11 do wait_settings = [wait_settings, '.IN' + letters(i) + 'P']

pseudomotor_settings = ['C1', $
                        'C2', $
                        'C3', $
                        'C4', $
                        'C5', $
                        '.OFF',  $
                        '.DHLM', $
                        '.DLLM', $
                        '.TWV',  $
                        '.DISA', $
                        '.DISP', $
                        ':scanParms.SP', $
                        ':scanParms.EP', $
                        ':scanParms.NP']

scaler_settings = ['.PREC', $
                   '.FREQ', $
                   '.TP', $
                   '.TP1', $
                   '.RATE', $
                   '.RAT1', $
                   '.DLY',  $
                   '.DLY1',  $
                   '.CONT',  $
                   '_calc_ctrl.VAL', $
                   '_calc1.CALC', $
                   '_calc2.CALC', $
                   '_calc3.CALC']
for i=1, 32 do scaler_settings = [scaler_settings, '.NM'+ numbers(i)]
for i=1, 32 do scaler_settings = [scaler_settings, '.PR'+ numbers(i)]
for i=1, 32 do scaler_settings = [scaler_settings, '.G' + numbers(i)]

dac_settings = ['_1.VAL']
for i=2, 8 do dac_settings = [dac_settings, '_'+numbers[i]+'.VAL']
for i=1, 8 do dac_settings = [dac_settings, '_'+numbers[i]+'_pulse.VAL']
for i=1, 8 do dac_settings = [dac_settings, '_'+numbers[i]+'_tweakVal.VAL']

dmm_settings = ['onesh_cont.VAL', $
                'single_multi.VAL', $
                'init_string.VAL', $
                'ch_mode_sel.VAL', $
                'dmm_chan.VAL', $
                'Dmm_raw.DESC', $
                'scanner.SCAN']
for i=1, 10 do dmm_settings = [dmm_settings, 'Ch'+numbers[i]+'_on_off.VAL']
for i=1, 10 do dmm_settings = [dmm_settings, 'ch'+numbers[i]+'_mode_sel.VAL']
dmm_settings = [dmm_settings, 'Dmm_calc.CALC']
dmm_settings = [dmm_settings, 'Dmm_calc.PREC']
dmm_settings = [dmm_settings, 'Dmm_calc.DESC']
; NOTE: there is a bug in save/restore so that input links in records are
; not correctly restored if they are in the auto_settings file.  They work OK
; if they are in the auto_positions file.  dmm_positions should be changed
; back to dmm_settings when this is fixed
dmm_positions = 'Dmm_calc.INPA'  ;  This is just to initialize the array
for i=0, 11 do begin
    dmm_settings = [dmm_settings, 'Dmm_calc.'+letters[i]]
;    dmm_settings = [dmm_settings, 'Dmm_calc.INP'+letters[i]]
    dmm_positions = [dmm_positions, 'Dmm_calc.INP'+letters[i]]
endfor
for i=1, 10 do begin
    for j=0, 11 do begin
        dmm_settings = [dmm_settings, 'Ch'+numbers[i]+'_calc.'+letters[j]]
;        dmm_settings = [dmm_settings, 'Ch'+numbers[i]+'_calc.INP'+letters[j]]
        dmm_positions = [dmm_positions, 'Ch'+numbers[i]+'_calc.INP'+letters[j]]
    endfor
    dmm_settings = [dmm_settings, 'Ch'+numbers[i]+'_calc.CALC']
    dmm_settings = [dmm_settings, 'Ch'+numbers[i]+'_calc.PREC']
    dmm_settings = [dmm_settings, 'Ch'+numbers[i]+'_calc.DESC']
    dmm_settings = [dmm_settings, 'Ch'+numbers[i]+'_raw.DESC']
endfor

fluke_8842A_settings = '_Init.AOUT'  ;  The initialization string
fluke_8842A_settings = $
         [fluke_8842A_settings, '_Read.SCAN',$     ;  The read rate
                                '_Convert.CALC',$  ;  The calculation
                                '_Convert.PREC',$  ;  The # digits
                                '_Convert.DESC',$  ;  The description
                                '_Convert.EGU', $  ;  Units
                                '_Calc.CALC',$     ;  The calculation
                                '_Calc.PREC',$     ;  The # digits
                                '_Calc.DESC',$     ;  The description
                                '_Calc.EGU']       ;  Units
for i=0, 11 do begin
    fluke_8842A_settings = [fluke_8842A_settings, '_Convert.INP'+letters[i]]
    fluke_8842A_settings = [fluke_8842A_settings, '_Calc.INP'+letters[i]]
endfor
for i=0, 5 do begin
    fluke_8842A_settings = [fluke_8842A_settings, '_Convert.IN'+letters[i]+letters[i]]
    fluke_8842A_settings = [fluke_8842A_settings, '_Calc.IN'+letters[i]+letters[i]]
endfor

; Heidenhein IK320
ik320_settings = '.B'
ik320_settings = [ik320_settings, 'direction.VAL', $
                                  'raw.DESC',      $ 
                                  'raw.EGU',       $
                                  'raw.ASLO',      $
                                  'prec.VAL']

; High resolution monochromator
hrm_settings = '_A1AO.VAL'
hrm_settings = [hrm_settings, '_H1AO.VAL', $
                              '_K1AO.VAL', $
                              '_L1AO.VAL', $
                              '_A2AO.VAL', $
                              '_H2AO.VAL', $
                              '_K2AO.VAL', $
                              '_L2AO.VAL', $
                              '_EAO.VAL',  $
                              '_Mode2MO.VAL', $
                              '_phi1OffAO', $
                              '_phi2OffAO', $
                              '_ETweakAI', $
                              '_LambdaTweakAI', $
                              '_Theta1TweakAI', $
                              '_Theta2TweakAI', $
                              '_worldTweakAI']


current_preamp_settings = ['bias_put.VAL', $
                           'bias_tweak.VAL', $
                           'bias_on.VAL', $
                           'off_u_put.VAL', $
                           'offset_u_tweak.VAL', $
                           'offset_cal.VAL', $
                           'filter_type.VAL', $
                           'low_freq.VAL', $
                           'high_freq.VAL', $
                           'offset_on.VAL', $
                           'offset_sign.VAL', $
                           'offset_num.VAL', $
                           'offset_unit.VAL', $
                           'gain_mode.VAL', $
                           'invert_on.VAL', $
                           'blank_on.VAL', $
                           'sens_num.VAL', $
                           'sens_unit.VAL']

icb_amp_settings = ['CGAIN', $
                    'FGAIN', $
                    'SFGAIN', $
                    'INPP', $
                    'INHP', $
                    'DMOD', $
                    'SMOD', $
                    'PTYP', $
                    'PURMOD', $
                    'BLMOD', $
                    'DTMOD', $
                    'PZ']

icb_adc_settings = ['GAIN', $
                    'OFFSET', $
                    'ULD', $
                    'LLD', $
                    'ZERO', $
                    'PMOD', $
                    'GMOD', $
                    'TMOD', $
                    'CMOD', $
                    'AMOD']

icb_dsp_settings = ['CG', $
                    'FG', $
                    'SFG', $
                    'ADCG', $
                    'ADCO', $
                    'LLD', $
                    'ZERO', $
                    'RT', $
                    'FT', $
                    'BLR', $
                    'PZM', $
                    'PZ', $
                    'THR', $
                    'FRQ', $
                    'GCOR', $
                    'ZCOR', $
                    'GMOD', $
                    'ZMOD', $
                    'GDIV', $
                    'ZDIV', $
                    'GSPC', $
                    'ZSPC', $
                    'GWND', $
                    'ZWND', $
                    'GCNT', $
                    'ZCNT', $
                    'GRAT', $
                    'ZRAT', $
                    'INPP', $
                    'INHP', $
                    'TINH', $
                    'FDM', $
                    'FD', $
                    'PURM', $
                    'GATM', $
                    'OUTM', $
                    'GD', $
                    'LTRM', $
                    'READ_SCAN.SCAN', $
                    'THRI']

icb_hvps_settings = ['VOLT_OUT', $
                     'VOLT_LIM', $
                     'INH_LEVEL', $
                     'LATCH_INH', $
                     'LATCH_OVL', $
                     'FRAMP']

icb_tca_settings =  ['POLARITY', $
                     'THRESHOLD', $
                     'SCA_ENABLE', $
                     'SCA1_GATE', $
                     'SCA2_GATE', $
                     'SCA3_GATE', $
                     'TCA_SELECT', $
                     'PUR_ENABLE', $
                     'SCA1_PUR', $
                     'SCA2_PUR', $
                     'SCA3_PUR', $
                     'PUR_AMP', $
                     'SCA1_LOW', $
                     'SCA1_HI', $
                     'SCA2_LOW', $
                     'SCA2_HI', $
                     'SCA3_LOW', $
                     'SCA3_HI', $
                     'ROI_SCA_ENABLE', $
                     'SCA_CAL']

feedback_settings = ['.INP', $
                     '.OUTL', $
                     '.VAL', $
                     '.SCAN', $
                     '.HOPR', $
                     '.LOPR', $
                     '.DRVL', $
                     '.DRVH', $
                     '.FMOD', $
                     '.KP', $
                     '.KI', $
                     '.KD']

mpc_settings = ['SAUTOS', $
                'DIS', $
                'SSIZE', $
                'ULCK', $
                'SIZE.SCAN', $
                'STAT.SCAN']

mpc_tsp_settings = ['TSP_FIL', $
                    'TSP_AUTO_ADV', $
                    'TSP_VALUE', $
                    'TSP_UNITS', $
                    'TSP_SECONDS', $
                    'TSP_MINUTES', $
                    'TSP_NCYCLES', $
                    'TSP_MIN_PRESS', $
                    'TSP_STAT.SCAN']


MAX_ROIS = 32
simple_mca_settings = [ $
                '.CALO', $
                '.CALS', $
                '.CALQ', $
                '.EGU',  $
                '.TTH',  $
                '.PRTM', $
                '.PLTM', $
                '.PCT',  $
                '.PCTL', $
                '.PCTH', $
                '.DWEL', $
                '.PSCL', $
                '.CHAS', $
                '.MODE']

dxp_settings = ['.GAIN', '.EMAX', '.PKTM', '.FIPPI', '.PGAIN']
for i=1, 9  do dxp_settings = [dxp_settings, '.A'+string(i, format='(i2.2)')+'V']
for i=1, 10 do dxp_settings = [dxp_settings, '.F'+string(i, format='(i2.2)')+'V']
for i=1, 10 do dxp_settings = [dxp_settings, '.D'+string(i, format='(i2.2)')+'V']
for i=1, 6  do dxp_settings = [dxp_settings, '.B'+string(i, format='(i2.2)')+'V']

for i=0, MAX_ROIS-1 do $
    simple_mca_settings = [simple_mca_settings,            $
                    '.R' + numbers(i) +'LO', $
                    '.R' + numbers(i) +'HI', $
                    '.R' + numbers(i) +'IP', $
                    '.R' + numbers(i) +'NM']
mca_settings = [simple_mca_settings, $
                'Read.SCAN', $
                'Status.SCAN']

smart_motors = ['TTH', 'OMEGA', 'PHI', 'KAPPA']
smart_settings = 'debugLevel'
for i=0, n_elements(smart_motors)-1 do begin
    smart_settings = [smart_settings, smart_motors[i]+'_EXISTS']
    smart_settings = [smart_settings, smart_motors[i]+'_OFFSET']
    smart_settings = [smart_settings, smart_motors[i]+'_SIGN']
    smart_settings = [smart_settings, smart_motors[i]+'_LOW_CUT']
    smart_settings = [smart_settings, smart_motors[i]+'_HIGH_CUT']
endfor

piezo_settings = ['.VAL', '_tweakVal']

openw, lun, /get, positions_file
for i=0, n_elements(motors)-1 do begin
   for j=0, n_elements(motor_positions)-1 do begin
      printf, lun, prefix + motors(i) + motor_positions(j)
   endfor
endfor
; NOTE: the following is needed for the bug in SAVE/RESTORE described above
; These should be in settings file, not positions file.
for i=0, n_elements(dmms)-1 do begin
   for j=0, n_elements(dmm_positions)-1 do begin
      printf, lun, prefix + dmms(i) + dmm_positions(j)
   endfor
endfor
free_lun, lun

openw, lun, /get, settings_file

for i=0, n_elements(motors)-1 do begin
   for j=0, n_elements(motor_settings)-1 do begin
      printf, lun, prefix + motors(i) + motor_settings(j)
   endfor
endfor

for i=0, n_elements(pseudomotors)-1 do begin
   for j=0, n_elements(pseudomotor_settings)-1 do begin
      printf, lun, prefix + pseudomotors(i) + pseudomotor_settings(j)
   endfor
endfor

for i=0, n_elements(scalers)-1 do begin
   for j=0, n_elements(scaler_settings)-1 do begin
      printf, lun, prefix + scalers(i) + scaler_settings(j)
   endfor
endfor

for i=0, n_elements(tables)-1 do begin
   for j=0, n_elements(table_settings)-1 do begin
      printf, lun, prefix + tables(i) + table_settings(j)
   endfor
endfor

for i=0, n_elements(scans)-1 do begin
   for j=0, n_elements(scan_settings)-1 do begin
      printf, lun, prefix + scans(i) + scan_settings(j)
   endfor
endfor

for i=0, n_elements(dacs)-1 do begin
   for j=0, n_elements(dac_settings)-1 do begin
      printf, lun, prefix + dacs(i) + dac_settings(j)
   endfor
endfor

for i=0, n_elements(dmms)-1 do begin
   for j=0, n_elements(dmm_settings)-1 do begin
      printf, lun, prefix + dmms(i) + dmm_settings(j)
   endfor
endfor

for i=0, n_elements(fluke_8842As)-1 do begin
   for j=0, n_elements(fluke_8842A_settings)-1 do begin
      printf, lun, prefix + fluke_8842As(i) + fluke_8842A_settings(j)
   endfor
endfor

for i=0, n_elements(ik320s)-1 do begin
   for j=0, n_elements(ik320_settings)-1 do begin
      printf, lun, prefix + ik320s(i) + ik320_settings(j)
   endfor
endfor

for i=0, n_elements(hrms)-1 do begin
   for j=0, n_elements(hrm_settings)-1 do begin
      printf, lun, prefix + hrms(i) + hrm_settings(j)
   endfor
endfor

for i=0, n_elements(current_preamps)-1 do begin
   for j=0, n_elements(current_preamp_settings)-1 do begin
      printf, lun, prefix + current_preamps(i) + current_preamp_settings(j)
   endfor
endfor

for i=0, n_elements(icb_amps)-1 do begin
   for j=0, n_elements(icb_amp_settings)-1 do begin
      printf, lun, prefix + icb_amps(i) + icb_amp_settings(j)
   endfor
endfor

for i=0, n_elements(icb_adcs)-1 do begin
   for j=0, n_elements(icb_adc_settings)-1 do begin
      printf, lun, prefix + icb_adcs(i) + icb_adc_settings(j)
   endfor
endfor

for i=0, n_elements(icb_dsps)-1 do begin
   for j=0, n_elements(icb_dsp_settings)-1 do begin
      printf, lun, prefix + icb_dsps(i) + icb_dsp_settings(j)
   endfor
endfor

for i=0, n_elements(icb_hvps)-1 do begin
   for j=0, n_elements(icb_hvps_settings)-1 do begin
      printf, lun, prefix + icb_hvps(i) + icb_hvps_settings(j)
   endfor
endfor

for i=0, n_elements(icb_tcas)-1 do begin
   for j=0, n_elements(icb_tca_settings)-1 do begin
      printf, lun, prefix + icb_tcas(i) + icb_tca_settings(j)
   endfor
endfor

for i=0, n_elements(feedback)-1 do begin
   for j=0, n_elements(feedback_settings)-1 do begin
      printf, lun, prefix + feedback(i) + feedback_settings(j)
   endfor
endfor

for i=0, n_elements(simple_mcas)-1 do begin
   for j=0, n_elements(simple_mca_settings)-1 do begin
      printf, lun, prefix + simple_mcas(i) + simple_mca_settings(j)
   endfor
endfor

for i=0, n_elements(dxps)-1 do begin
   for j=0, n_elements(dxp_settings)-1 do begin
      printf, lun, prefix + dxps(i) + dxp_settings(j)
   endfor
endfor

for i=0, n_elements(mcas)-1 do begin
   for j=0, n_elements(mca_settings)-1 do begin
      printf, lun, prefix + mcas(i) + mca_settings(j)
   endfor
endfor

for i=0, n_elements(smart)-1 do begin
   for j=0, n_elements(smart_settings)-1 do begin
      printf, lun, prefix + smart(i) + smart_settings(j)
   endfor
endfor

for i=0, n_elements(piezos)-1 do begin
   for j=0, n_elements(piezo_settings)-1 do begin
      printf, lun, prefix + piezos(i) + piezo_settings(j)
   endfor
endfor

for i=0, n_elements(mpcs)-1 do begin
   for j=0, n_elements(mpc_settings)-1 do begin
      printf, lun, prefix + mpcs(i) + mpc_settings(j)
   endfor
endfor

for i=0, n_elements(mpc_tsps)-1 do begin
   for j=0, n_elements(mpc_tsp_settings)-1 do begin
      printf, lun, prefix + mpc_tsps(i) + mpc_tsp_settings(j)
   endfor
endfor


if (n_elements(energy) ne 0) then begin
    energy_settings = ['width','dspace','height','id_off','id_track','use_id',$
                       'z2_track','z2_off','y2_track','y2_off',$
                       'xt_track','xt_sign','xt_mvmin','xt_off',$
                       'verbose','tweakval']
    for j=0, n_elements(energy_settings)-1 do begin
        printf, lun, prefix + energy + ':' + energy_settings(j)  + '.VAL'
    endfor
endif

for i=0, n_elements(user_transform)-1 do begin
    utran_p = ['CMT','INP','CLC']
    utran_l = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P']
    for j=0, n_elements(utran_p)-1 do begin
        for k=0, n_elements(utran_l)-1 do begin
            printf, lun, prefix + user_transform[i] + '.' + utran_p[j] + utran_l[k]
        endfor
    endfor
endfor


if (n_elements(newport_snl) ne 0) then begin
    settings = ['lx', 'lz', 'D0x', 'D0y', 'D0z', 'd1', 'd2']
    for j=0, n_elements(settings)-1 do begin
        printf, lun, prefix + newport_snl(0) + settings(j)
    endfor

    for j=1, n_elements(newport_snl)-1 do begin
        printf, lun, prefix + newport_snl(j) + ':Readback'
    endfor

endif


free_lun, lun

; Create the scanParams.template file
openw, lun, /get, scanparms_file
printf, lun, 'file stdApp/Db/scanParms.db, std'
printf, lun, '{'
for i=0, n_elements(motors)-1 do begin
    printf, lun, '{P=' + prefix + ',SCANREC=' + prefix + 'scan1' + ',Q=' $
                 + motors[i] + ',POS=' + motors[i] + '.VAL,RDBK='  $
                 + motors[i] + '.RBV}'
endfor
for i=0, n_elements(pseudomotors)-1 do begin
    printf, lun, '{P=' + prefix + ',SCANREC=' + prefix + 'scan1' + ',Q=' $
                 + pseudomotors[i] + ',POS=' + pseudomotors[i] + '.VAL,RDBK=' $
                 + pseudomotors[i] + '.RBV}'
endfor
for i=0, n_elements(dacs)-1 do begin
    for j=1, 8 do begin
        suffix = '_' + strtrim(j,2)
        printf, lun, '{P=' + prefix + ',' + $
                 'SCANREC=' + prefix + 'scan1,' + $
                 'Q=' + dacs[i] + suffix + ',' + $
                 'POS='  + dacs[i] + suffix + '.VAL,' + $
                 'RDBK=' + dacs[i] + suffix + '.VAL}'
    endfor
endfor
printf, lun, '}'
free_lun, lun

end

