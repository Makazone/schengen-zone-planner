import React from "react";
import moment, { duration } from "moment";
import { Grid, Button, Label } from "semantic-ui-react";
import CalendarView from "react-year-calendar";

const CalendarContainer = props => {
  const { trips, daysLeft, dateEntry } = props;

  console.log(trips);
  console.log(daysLeft);
  console.log(dateEntry);

  const modsBetweenDates = (dateStart, dateEnd) => {
    const a = dateStart;
    const b = dateEnd;
    // console.log(moment(a).format());
    // console.log(b.format());
    let newMods = [];
    for (var m = a; m.diff(b, "days") <= 0; m.add(1, "days")) {
      // console.log(m.format());
      // console.log(m.diff(b, "days"));
      //   console.log(m)
      newMods.push({
        date: moment(m),
        classNames: ["current"],
        component: ["day"]
      });
    }
    return newMods;
  };

  let mods = [
    {
      component: ["day"],
      events: {
        onClick: date => {
          window.location.href = `/calendar?date_entry=${date}`;
        }
      }
    }
  ];

  mods = trips.reduce((mods, t) => {
    const startDate = moment(t.start_date);
    const endDate = moment(t.end_date);
    return [...mods, ...modsBetweenDates(startDate, endDate)];
  }, mods);

  if (dateEntry) {
    mods = mods.concat(
      modsBetweenDates(
        moment(dateEntry),
        moment(dateEntry).add(daysLeft, "days")
      )
    );
  }

  // console.log(mods);

  const startDate = moment().startOf("year");
  const endDate = moment().endOf("year");

  return (
    <CalendarView
      startDate={startDate}
      endDate={endDate}
      weekNumbers={true}
      size={12}
      mods={mods}
    />
  );
};

export default CalendarContainer;
