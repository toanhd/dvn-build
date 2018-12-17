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

    let availGrade = false;

    //Get Factory to create new resource
    let factory = getFactory();

    if (availStd && availLec) {
        if (availTranscript) {

            var transcript = await transcriptReg.get(transcriptID);
            let inputGradeid = gradeID = transcriptID + "_grade" + GradingTx.courseID;

            function containsObject(id, list) {
                var i;
                for (i = 0; i < list.length; i++) {
                    if (list[i].gradeID === id) {
                        return true;
                    }
                }
                return false;
            }

            if (containsObject(inputGradeid, transcript.gradesList)) {
                const avalStatus = "thisGradeIDIsAvail";
                throw new ReferenceError(
                    avalStatus
                )
            } else {
                //Create new Grade
                let newGrade = factory.newConcept('org.dvn.com', 'Grade');

                newGrade.transcriptID = transcriptID;
                newGrade.gradeID = inputGradeid;
                newGrade.issueDate = GradingTx.timestamp;
                newGrade.courseID = GradingTx.courseID;
                newGrade.courseName = GradingTx.courseName;
                newGrade.credit = GradingTx.credit;
                newGrade.gradeVal = GradingTx.gradeVal;
                newGrade.semester = GradingTx.semester;

                //Create relationship
                newGrade.lecturer = factory.newRelationship('org.dvn.com', 'Lecturer', GradingTx.lecID);
                newGrade.student = factory.newRelationship('org.dvn.com', 'Student', GradingTx.stdID);

                //Save new grade to transcript
                transcript.gradesList.push(newGrade);

                //Update transcript to transcript registry
                await transcriptReg.update(transcript);
            }


        } else { //this student transcript is not exist
            //Create new Transcript
            let newTranscript = factory.newResource('org.dvn.com', 'Transcript', transcriptID);

            //Tao relationship cho doi tuong reference
            newTranscript.student = factory.newRelationship('org.dvn.com', 'Student', GradingTx.stdID);
            newTranscript.lecturer = factory.newRelationship('org.dvn.com', 'Lecturer', GradingTx.lecID);
            newTranscript.gradesList = [];

            let newGrade = factory.newConcept('org.dvn.com', 'Grade');

            newGrade.transcriptID = transcriptID;
            newGrade.gradeID = transcriptID + "_grade" + GradingTx.courseID;
            newGrade.issueDate = GradingTx.timestamp;
            newGrade.courseID = GradingTx.courseID;
            newGrade.courseName = GradingTx.courseName;
            newGrade.credit = GradingTx.credit;
            newGrade.gradeVal = GradingTx.gradeVal;
            newGrade.semester = GradingTx.semester;

            //Create relationship
            newGrade.lecturer = factory.newRelationship('org.dvn.com', 'Lecturer', GradingTx.lecID);
            newGrade.student = factory.newRelationship('org.dvn.com', 'Student', GradingTx.stdID);

            //Save new grade to transcript
            newTranscript.gradesList.push(newGrade);

            //add transcript to transcript registry
            await transcriptReg.add(newTranscript);
        }
        console.log("go here");

        //Create new event
        let GradingEvent = factory.newEvent('org.dvn.com', 'GradingEvent');
        GradingEvent.gradingTransaction = GradingTx;
        GradingEvent.action = action;
        //Emit event
        emit(GradingEvent);
    } else {
        const avalStatus = "availStd: " + availStd + ", availecturer:" + availLec + ", avaitranscript:" + availTranscript;
        throw new ReferenceError(
            avalStatus
        )
    }
}

