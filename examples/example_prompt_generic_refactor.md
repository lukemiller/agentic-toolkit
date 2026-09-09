## Refactoring Plan

This `UserDashboard` component is 400 lines long. Refactor it by:

- extracting the stats cards into a `StatsGrid` component
- the activity feed into an `ActivityFeed` component
- the sidebar navigation into a `DashboardNav` component

## Requirements:

- Keep the data fetching in `UserDashboard` and pass data down as props.
- Create TypeScript interfaces for all props.
- Preserve all existing functionality and don't change any CSS class names.