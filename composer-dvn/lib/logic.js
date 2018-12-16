/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';
/**
 * Write your transction processor functions here
 */

/**
 * Sample transaction
 * @param {org.dvn.com.Grading} Grading
 * @transaction
 */
async function Grading(GradingTx) {
    //Action type
    let action = '';
    //create format for transcript id
    let transcriptID = "transcript_" + GradingTx.stdID;
    //Asset Registry for object type Transcript
    let transcriptReg = await getAssetRegistry('org.dvn.com.Transcript');
    //check existence of transcript
    let availTranscript = await transcriptReg.exists(transcriptID);

    //Asset Registry for object type Student
    let studentReg = await getParticipantRegistry('org.dvn.com.Student');
    //check existence of student
    let availStd = await studentReg.exists(GradingTx.stdID);

    //Asset Registry for object type Lecturer
    let lecReg = await getParticipantRegistry('org.dvn.com.Lecturer');
    //check existence of student
    let availLec = await lecReg.exists(GradingTx.lecID);

    //Get Factory to create new resource
    let factory = getFactory();

    //Asset Registry for object type Grade
    let gradeReg = await getAssetRegistry('org.dvn.com.Grade');

    if (availStd && availLec) {
        if (availTranscript) {

            var transcript = await transcriptReg.get(transcriptID);

            //Create new Grade
            let gradeID = transcriptID + "_grade" + GradingTx.courseID;
            let newGrade = factory.newResource('org.dvn.com', 'Grade', gradeID.toString());

            newGrade.transcriptID = transcriptID;
            newGrade.issueDate = GradingTx.timestamp;
            newGrade.courseID = GradingTx.courseID;
            newGrade.courseName = GradingTx.courseName;
            newGrade.credit = GradingTx.credit;
            newGrade.gradeVal = GradingTx.gradeVal;
            newGrade.semester = GradingTx.semester;

            //Create relationship
            newGrade.lecturer = factory.newRelationship('org.dvn.com', 'Lecturer', GradingTx.lecID);
            newGrade.student = factory.newRelationship('org.dvn.com', 'Student', GradingTx.stdID);

            //Update grade to grade registry
            await gradeReg.add(newGrade);

            //Save new grade to transcript
            transcript.gradeIDsList.push(gradeID);

            //Update transcript to transcript registry
            await transcriptReg.update(transcript);

        } else { //this student transcript is not exist
            //Create new Transcript
            let newTranscript = factory.newResource('org.dvn.com', 'Transcript', transcriptID);
          
            //Tao relationship cho doi tuong reference
            newTranscript.student = factory.newRelationship('org.dvn.com', 'Student', GradingTx.stdID);
            newTranscript.lecturer = factory.newRelationship('org.dvn.com', 'Lecturer', GradingTx.lecID);
            newTranscript.gradeIDsList = [];

            //Create new Grade
            let gradeID = transcriptID + "_grade" + GradingTx.courseID;
            let newGrade = factory.newResource('org.dvn.com', 'Grade', gradeID.toString());
            newGrade.transcriptID = transcriptID;
            newGrade.issueDate = GradingTx.timestamp;
            newGrade.courseID = GradingTx.courseID;
            newGrade.courseName = GradingTx.courseName;
            newGrade.credit = GradingTx.credit;
            newGrade.gradeVal = GradingTx.gradeVal;
            newGrade.semester = GradingTx.semester;

            //Create relationship
            newGrade.lecturer = factory.newRelationship('org.dvn.com', 'Lecturer', GradingTx.lecID);
            newGrade.student = factory.newRelationship('org.dvn.com', 'Student', GradingTx.stdID);

            //Update grade to grade registry
            await gradeReg.add(newGrade);

            //Save new grade to transcript
            newTranscript.gradeIDsList.push(gradeID);

            //add transcript to transcript registry
            await transcriptReg.add(newTranscript);
        }
        //Create new event
        let GradingEvent = factory.newEvent('org.dvn.com', 'GradingEvent');
        GradingEvent.gradingTransaction = GradingTx;
        GradingEvent.action = action;

        //Emit event
        emit(GradingEvent);
    } else {
        const avalStatus = {
            student: availStd,
            lecturer: availLec,
            transcript: availTranscript
        };
        throw new ReferenceError(
            avalStatus
        )
    }
}
